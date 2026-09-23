import '../../models/mobile/mobile_bootstrap_model.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class MobileRepository {
  Future<MobileBootstrapResponse> getMobileBootstrap() async {
    final response = await ApiService.get<Map<String, dynamic>>(
      EndPoints.mobileBootstrap,
    );
    return MobileBootstrapResponse.fromJson(response.data ?? const {});
  }

  Future<SelectedBranchResponse> selectMobileBranch(String branchId) async {
    final response = await ApiService.put<Map<String, dynamic>>(
      EndPoints.mobileBranchSelection,
      data: {'branch_id': branchId},
    );
    return SelectedBranchResponse.fromJson(response.data ?? const {});
  }
}
