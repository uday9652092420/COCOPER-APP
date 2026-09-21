import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'secure_storage_helper.dart';

abstract final class CacheHelper {
  static const _cacheBoxName = 'cocoper_cache_v2';
  static const _draftBoxName = 'cocoper_drafts_v2';
  static const _queueBoxName = 'cocoper_sync_queue_v2';
  static const _cipherKeyName = 'cocoper_hive_cipher_v2';

  static Future<void> init() async {
    await Hive.initFlutter('cocoper');
    var encodedKey = await SecureStorageHelper.read(_cipherKeyName);
    if (encodedKey == null) {
      encodedKey = base64UrlEncode(Hive.generateSecureKey());
      await SecureStorageHelper.write(_cipherKeyName, encodedKey);
    }
    final cipher = HiveAesCipher(base64Url.decode(encodedKey));
    await Future.wait([
      Hive.openBox<String>(_cacheBoxName, encryptionCipher: cipher),
      Hive.openBox<String>(_draftBoxName, encryptionCipher: cipher),
      Hive.openBox<String>(_queueBoxName, encryptionCipher: cipher),
    ]);
  }

  static Box<String> get cache => Hive.box<String>(_cacheBoxName);
  static Box<String> get drafts => Hive.box<String>(_draftBoxName);
  static Box<String> get queue => Hive.box<String>(_queueBoxName);

  static Future<void> putJson(Box<String> box, String key, Object value) =>
      box.put(key, jsonEncode(value));

  static Map<String, dynamic>? readMap(Box<String> box, String key) {
    final raw = box.get(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<dynamic, dynamic>) return null;
    return decoded.map((key, value) => MapEntry('$key', value));
  }
}

class CacheEnvelope {
  const CacheEnvelope({required this.savedAt, required this.data});

  factory CacheEnvelope.fromJson(Map<String, dynamic> json) => CacheEnvelope(
        savedAt: DateTime.parse(json['savedAt'] as String),
        data: json['data'],
      );

  final DateTime savedAt;
  final Object? data;

  bool isFresh(Duration ttl) => DateTime.now().difference(savedAt) < ttl;

  Map<String, dynamic> toJson() => {
        'savedAt': savedAt.toUtc().toIso8601String(),
        'data': data,
      };
}
