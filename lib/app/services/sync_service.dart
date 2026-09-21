import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../helpers/cache_helper.dart';
import 'api_service.dart';
import 'exceptions.dart';

class PendingMutation {
  const PendingMutation({
    required this.id,
    required this.path,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });

  factory PendingMutation.fromJson(Map<String, dynamic> json) =>
      PendingMutation(
        id: json['id'] as String,
        path: json['path'] as String,
        method: json['method'] as String,
        payload: (json['payload'] as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry('$key', value),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String path;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;

  PendingMutation withAttempt() => PendingMutation(
        id: id,
        path: path,
        method: method,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts + 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'method': method,
        'payload': payload,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'attempts': attempts,
      };
}

abstract final class SyncService {
  static final pendingCount = 0.obs;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _flushing = false;

  static Future<void> initialize() async {
    pendingCount.value = CacheHelper.queue.length;
    _subscription ??= Connectivity().onConnectivityChanged.listen((states) {
      if (!states.contains(ConnectivityResult.none)) unawaited(flush());
    });
    unawaited(flush());
  }

  static Future<String> enqueue({
    required String path,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    final mutation = PendingMutation(
      id: const Uuid().v4(),
      path: path,
      method: method,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await CacheHelper.queue.put(mutation.id, jsonEncode(mutation.toJson()));
    pendingCount.value = CacheHelper.queue.length;
    unawaited(flush());
    return mutation.id;
  }

  static Future<void> flush() async {
    if (_flushing || CacheHelper.queue.isEmpty) return;
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;
    _flushing = true;
    try {
      for (final key in CacheHelper.queue.keys.toList(growable: false)) {
        final raw = CacheHelper.queue.get(key);
        if (raw == null) continue;
        final mutation = PendingMutation.fromJson(
          (jsonDecode(raw) as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry('$key', value),
          ),
        );
        try {
          await ApiService.request<void>(
            mutation.path,
            method: mutation.method,
            data: mutation.payload,
            headers: {'X-Idempotency-Key': mutation.id},
          );
          await CacheHelper.queue.delete(key);
          pendingCount.value = CacheHelper.queue.length;
        } on ValidationException {
          await _recordAttempt(mutation);
          continue;
        } on SessionExpiredException {
          await _recordAttempt(mutation);
          break;
        } on AppException {
          await _recordAttempt(mutation);
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  static Future<void> _recordAttempt(PendingMutation mutation) =>
      CacheHelper.queue
          .put(mutation.id, jsonEncode(mutation.withAttempt().toJson()));
}
