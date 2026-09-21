import '../../config/constants.dart';
import '../../config/environment.dart';
import '../../helpers/cache_helper.dart';
import '../../models/transactions/transaction_model.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';
import '../../services/exceptions.dart';
import '../../services/sync_service.dart';

class TransactionRepository {
  Future<List<TransactionRecord>> getTransactions({
    required TransactionType type,
    required String branchId,
    String search = '',
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'transactions:${type.name}:$branchId';
    final cached = CacheHelper.readMap(CacheHelper.cache, cacheKey);
    if (!forceRefresh && cached != null) {
      final envelope = CacheEnvelope.fromJson(cached);
      if (envelope.isFresh(AppConstants.cacheTtl) &&
          envelope.data is List<dynamic>) {
        return _filter(_decodeRecords(envelope.data! as List<dynamic>), search);
      }
    }

    try {
      final records = Environment.useMockBackend
          ? await _mockTransactions(type, branchId)
          : await _loadRemote(type, branchId, search);
      await _cacheRecords(cacheKey, records);
      return _filter(records, search);
    } on NetworkException {
      if (cached?['data'] is List<dynamic>) {
        return _filter(
          _decodeRecords(cached!['data'] as List<dynamic>),
          search,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, List<String>>> getLookups({
    required String branchId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'lookups:$branchId';
    final cached = CacheHelper.readMap(CacheHelper.cache, cacheKey);
    if (!forceRefresh && cached != null) {
      final envelope = CacheEnvelope.fromJson(cached);
      if (envelope.isFresh(AppConstants.lookupCacheTtl) &&
          envelope.data is Map<dynamic, dynamic>) {
        return _decodeLookups(envelope.data! as Map<dynamic, dynamic>);
      }
    }
    try {
      final data = Environment.useMockBackend
          ? _mockLookups
          : (await ApiService.get<Map<String, dynamic>>(
                EndPoints.transactionLookups,
                queryParameters: {'branchId': branchId},
              ))
                  .data ??
              const <String, dynamic>{};
      await CacheHelper.putJson(
        CacheHelper.cache,
        cacheKey,
        CacheEnvelope(savedAt: DateTime.now(), data: data).toJson(),
      );
      return _decodeLookups(data);
    } on NetworkException {
      if (cached?['data'] is Map<dynamic, dynamic>) {
        return _decodeLookups(cached!['data'] as Map<dynamic, dynamic>);
      }
      rethrow;
    }
  }

  Future<TransactionRecord> createTransaction(
    TransactionCreateRequest request,
  ) async {
    final party = request.values[FieldKey.customer.name] ??
        request.values[FieldKey.supplier.name] ??
        request.values[FieldKey.labour.name] ??
        request.values[FieldKey.temporaryWorkerName.name] ??
        'COCOPER';

    if (Environment.useMockBackend) {
      final record = TransactionRecord(
        id: 'DEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        type: request.type,
        party: party,
        date: request.clientCreatedAt,
        status: 'Approved',
        amount: TransactionCalculator.total(request.type, request.values),
        summary: request.values[FieldKey.quantityMode.name] ?? 'Demo',
        branchId: request.branchId,
      );
      await _prependToCache(record);
      return record;
    }

    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        EndPoints.transactions(request.type.apiValue),
        data: request.toJson(),
      );
      return TransactionRecord.fromJson(response.data!);
    } on NetworkException {
      final queueId = await SyncService.enqueue(
        path: EndPoints.transactions(request.type.apiValue),
        method: 'POST',
        payload: request.toJson(),
      );
      final record = TransactionRecord(
        id: 'LOCAL-${queueId.substring(0, 6).toUpperCase()}',
        type: request.type,
        party: party,
        date: request.clientCreatedAt,
        status: 'Pending sync',
        amount: TransactionCalculator.total(request.type, request.values),
        summary: request.values[FieldKey.quantityMode.name] ?? 'Offline',
        branchId: request.branchId,
        syncPending: true,
      );
      await _prependToCache(record);
      return record;
    }
  }

  TransactionDraft? readDraft(TransactionType type) {
    final json = CacheHelper.readMap(CacheHelper.drafts, 'draft:${type.name}');
    return json == null ? null : TransactionDraft.fromJson(json);
  }

  Future<void> saveDraft(TransactionDraft draft) => CacheHelper.putJson(
        CacheHelper.drafts,
        'draft:${draft.type.name}',
        draft.toJson(),
      );

  Future<void> clearDraft(TransactionType type) =>
      CacheHelper.drafts.delete('draft:${type.name}');

  Future<List<TransactionRecord>> _loadRemote(
    TransactionType type,
    String branchId,
    String search,
  ) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      EndPoints.transactions(type.apiValue),
      queryParameters: {
        'branchId': branchId,
        'search': search,
        'page': 1,
        'pageSize': AppConstants.pageSize,
      },
    );
    return PaginatedTransactions.fromJson(response.data!).items;
  }

  Future<void> _cacheRecords(String key, List<TransactionRecord> records) =>
      CacheHelper.putJson(
        CacheHelper.cache,
        key,
        CacheEnvelope(
          savedAt: DateTime.now(),
          data: records.map((record) => record.toJson()).toList(),
        ).toJson(),
      );

  Future<void> _prependToCache(TransactionRecord record) async {
    final key = 'transactions:${record.type.name}:${record.branchId}';
    final cached = CacheHelper.readMap(CacheHelper.cache, key);
    final existing = cached?['data'] is List<dynamic>
        ? cached!['data'] as List<dynamic>
        : const <dynamic>[];
    await CacheHelper.putJson(
      CacheHelper.cache,
      key,
      CacheEnvelope(
        savedAt: DateTime.now(),
        data: [record.toJson(), ...existing],
      ).toJson(),
    );
  }

  List<TransactionRecord> _decodeRecords(List<dynamic> items) => items
      .map(
        (item) => TransactionRecord.fromJson(
          (item as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry('$key', value),
          ),
        ),
      )
      .toList(growable: false);

  Map<String, List<String>> _decodeLookups(Map<dynamic, dynamic> data) =>
      data.map(
        (key, value) => MapEntry(
          '$key',
          (value as List<dynamic>).map((item) => '$item').toList(),
        ),
      );

  List<TransactionRecord> _filter(
    List<TransactionRecord> records,
    String search,
  ) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where(
          (record) => '${record.id} ${record.party} ${record.summary}'
              .toLowerCase()
              .contains(query),
        )
        .toList(growable: false);
  }

  Future<List<TransactionRecord>> _mockTransactions(
    TransactionType type,
    String branchId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final parties = switch (type) {
      TransactionType.sales ||
      TransactionType.customerReceipt ||
      TransactionType.loadingDispatch =>
        [
          'Anand Stores',
          'Green Mart',
          'Mahalakshmi Foods',
        ],
      TransactionType.labourPayment => ['Ramesh', 'Selvam', 'Kumar'],
      _ => ['Lakshmi Traders', 'Ravi Coconut Farm', 'Muthu Agro'],
    };
    return List.generate(6, (index) {
      return TransactionRecord(
        id: '${type.apiValue.substring(0, 2).toUpperCase()}-${448 - index}',
        type: type,
        party: parties[index % parties.length],
        date: DateTime.now().subtract(Duration(days: index)),
        status: index == 1 ? 'Pending' : 'Approved',
        amount: 24500 + index * 12750,
        summary: index.isEven ? 'Tonnage • 2.5 t' : 'Piece wise • 1,800 pcs',
        branchId: branchId,
      );
    });
  }

  static const _mockLookups = <String, List<String>>{
    'branches': ['Bengaluru Main', 'Tumakuru Yard', 'Chennai Hub'],
    'suppliers': ['Ravi Coconut Farm', 'Lakshmi Traders', 'Muthu Agro'],
    'customers': ['Anand Stores', 'Green Mart', 'Mahalakshmi Foods'],
    'warehouses': ['Main Yard', 'Godown 2', 'East Warehouse'],
    'items': [
      'Premium Coconut',
      'Medium Coconut',
      'Small Coconut',
      'Dry Coconut',
      'Tender Coconut',
    ],
    'bags': ['Jute Bag', 'COCOS Inner Bag', 'Sai Ram Bag', 'Jamindar Bag'],
    'labour': ['Ramesh', 'Selvam', 'Kumar', 'Mani'],
    'expenseHeads': [
      'Fuel & transport',
      'Maintenance',
      'Electricity & utilities',
      'Office expenses',
    ],
    'customerInvoices': ['DS-0821 • ₹32,400', 'DS-0818 • ₹18,500'],
    'supplierInvoices': ['PI-0448 • ₹74,500', 'PI-0446 • ₹91,800'],
  };
}
