import '../../config/constants.dart';
import '../../config/environment.dart';
import '../../helpers/cache_helper.dart';
import '../../models/reports/report_model.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';
import '../../services/exceptions.dart';

class ReportRepository {
  Future<ReportData> getReport(
    ReportQuery query, {
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'report:${query.type.name}:${query.branchId}:${query.range.name}:${query.partyId ?? '-'}';
    final cached = CacheHelper.readMap(CacheHelper.cache, cacheKey);
    if (!forceRefresh && cached != null) {
      final envelope = CacheEnvelope.fromJson(cached);
      if (envelope.isFresh(AppConstants.cacheTtl) &&
          envelope.data is Map<dynamic, dynamic>) {
        return _decodeReport(envelope.data! as Map<dynamic, dynamic>);
      }
    }

    try {
      final report = Environment.useMockBackend
          ? await _mockReport(query)
          : await _loadRemote(query);
      await CacheHelper.putJson(
        CacheHelper.cache,
        cacheKey,
        CacheEnvelope(savedAt: DateTime.now(), data: report.toJson()).toJson(),
      );
      return report;
    } on NetworkException {
      if (cached?['data'] is Map<dynamic, dynamic>) {
        return _decodeReport(cached!['data'] as Map<dynamic, dynamic>);
      }
      rethrow;
    }
  }

  Future<String> createExport(ReportQuery query) async {
    if (Environment.useMockBackend) {
      return 'demo://reports/${query.type.apiValue}';
    }
    final response = await ApiService.post<Map<String, dynamic>>(
      EndPoints.reportExport(query.type.apiValue),
      data: {
        'branchId': query.branchId,
        'range': query.range.name,
        if (query.partyId != null) 'partyId': query.partyId,
      },
    );
    return response.data?['downloadUrl']?.toString() ?? '';
  }

  Future<ReportData> _loadRemote(ReportQuery query) async {
    final response = await ApiService.get<Map<String, dynamic>>(
      EndPoints.reports(query.type.apiValue),
      queryParameters: {
        'branchId': query.branchId,
        'range': query.range.name,
        if (query.partyId != null) 'partyId': query.partyId,
      },
    );
    return ReportData.fromJson(response.data!);
  }

  ReportData _decodeReport(Map<dynamic, dynamic> data) =>
      ReportData.fromJson(data.map((key, value) => MapEntry('$key', value)));

  Future<ReportData> _mockReport(ReportQuery query) async {
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (query.type == ReportType.profitLoss) {
      return const ReportData(
        type: ReportType.profitLoss,
        summary: '₹16,10,064',
        subtitle: '20.1% net margin',
        metrics: {
          'Total sales': '₹79,96,440',
          'Purchases / COGS': '₹66,22,241',
          'Gross profit': '₹13,74,199',
          'Operating expenses': '₹1,34,289',
          'Other income': '₹3,70,154',
        },
        rows: [],
      );
    }
    if (query.type == ReportType.customerStatement ||
        query.type == ReportType.supplierStatement) {
      final customer = query.type == ReportType.customerStatement;
      return ReportData(
        type: query.type,
        summary: customer ? '₹2,84,500' : '₹6,68,912',
        subtitle: customer ? 'Customer balance' : 'Supplier balance',
        parties: customer
            ? const ['Green Mart', 'Anand Stores', 'Mahalakshmi Foods']
            : const ['Ravi Coconut Farm', 'Lakshmi Traders', 'Muthu Agro'],
        rows: const [
          ReportRow(
            primary: '24 Jul',
            secondary: 'DS-0821',
            tertiary: 'Sale',
            value: '₹32,400',
          ),
          ReportRow(
            primary: '23 Jul',
            secondary: 'RC-0928',
            tertiary: 'Receipt',
            value: '₹20,000',
            credit: true,
          ),
          ReportRow(
            primary: '18 Jul',
            secondary: 'DS-0818',
            tertiary: 'Sale',
            value: '₹18,500',
          ),
        ],
      );
    }

    final rows = switch (query.type) {
      ReportType.purchaseRegister => const [
          ReportRow(
            primary: '30 Jul',
            secondary: 'PI-0448',
            tertiary: 'Lakshmi Traders',
            value: '₹74,500',
          ),
          ReportRow(
            primary: '29 Jul',
            secondary: 'PI-0447',
            tertiary: 'Ravi Coconut Farm',
            value: '₹51,300',
          ),
          ReportRow(
            primary: '28 Jul',
            secondary: 'PI-0446',
            tertiary: 'Muthu Agro',
            value: '₹91,800',
          ),
        ],
      ReportType.salesRegister => const [
          ReportRow(
            primary: '30 Jul',
            secondary: 'SO-0821',
            tertiary: 'Anand Stores',
            value: '₹32,400',
          ),
          ReportRow(
            primary: '30 Jul',
            secondary: 'SO-0820',
            tertiary: 'Green Mart',
            value: '₹48,650',
          ),
          ReportRow(
            primary: '29 Jul',
            secondary: 'SO-0819',
            tertiary: 'Mahalakshmi Foods',
            value: '₹26,900',
          ),
        ],
      ReportType.labourAttendance => const [
          ReportRow(
            primary: 'Jul 2026',
            secondary: 'Ramesh',
            tertiary: '26 days',
            value: '₹3,600',
          ),
          ReportRow(
            primary: 'Jul 2026',
            secondary: 'Selvam',
            tertiary: '25 days',
            value: '₹2,850',
          ),
          ReportRow(
            primary: 'Jul 2026',
            secondary: 'Kumar',
            tertiary: '24 days',
            value: '₹3,150',
          ),
        ],
      ReportType.pendingDispatch => const [
          ReportRow(
            primary: '30 Jul',
            secondary: 'DISP-0312',
            tertiary: 'Green Mart',
            value: '120 bags',
          ),
          ReportRow(
            primary: '30 Jul',
            secondary: 'DISP-0313',
            tertiary: 'Anand Stores',
            value: '80 bags',
          ),
          ReportRow(
            primary: '29 Jul',
            secondary: 'DISP-0309',
            tertiary: 'Fresh Foods',
            value: '45 bags',
          ),
        ],
      ReportType.outstanding => const [
          ReportRow(
            primary: 'Customer',
            secondary: 'CUS-001',
            tertiary: 'Anand Stores',
            value: '₹2,84,500',
          ),
          ReportRow(
            primary: 'Supplier',
            secondary: 'SUP-001',
            tertiary: 'Ravi Coconut Farm',
            value: '₹6,68,912',
          ),
          ReportRow(
            primary: 'Customer',
            secondary: 'CUS-002',
            tertiary: 'Green Mart',
            value: '₹1,42,700',
          ),
        ],
      _ => const <ReportRow>[],
    };
    final summary = switch (query.type) {
      ReportType.purchaseRegister => '₹7.45L',
      ReportType.salesRegister => '₹8.92L',
      ReportType.labourAttendance => '25 present',
      ReportType.pendingDispatch => '12 loads',
      ReportType.outstanding => '₹12.5L',
      _ => '—',
    };
    return ReportData(type: query.type, summary: summary, rows: rows);
  }
}
