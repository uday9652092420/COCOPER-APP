class MobileUser {
  const MobileUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.mobileNo,
    required this.role,
    required this.userType,
    required this.profilePicture,
  });

  factory MobileUser.fromJson(Map<String, dynamic> json) => MobileUser(
        id: _string(json['id']),
        username: _string(json['username']),
        fullName: _string(json['full_name'] ?? json['fullName']),
        email: _string(json['email']),
        mobileNo: _string(json['mobile_no'] ?? json['mobileNo']),
        role: _string(json['role']),
        userType: _string(json['user_type'] ?? json['userType']),
        profilePicture:
            _string(json['profile_picture'] ?? json['profilePicture']),
      );

  final String id;
  final String username;
  final String fullName;
  final String email;
  final String mobileNo;
  final String role;
  final String userType;
  final String profilePicture;
}

class MobileOrganization {
  const MobileOrganization({
    required this.id,
    required this.code,
    required this.name,
    required this.logoUrl,
    required this.contactNo,
    required this.email,
    required this.address,
  });

  factory MobileOrganization.fromJson(Map<String, dynamic> json) =>
      MobileOrganization(
        id: _string(json['id']),
        code: _string(json['organization_code'] ?? json['organizationCode']),
        name: _string(json['organization_name'] ?? json['organizationName']),
        logoUrl: _string(json['logo_url'] ?? json['logoUrl']),
        contactNo: _string(json['contact_no'] ?? json['contactNo']),
        email: _string(json['email']),
        address: _string(json['address']),
      );

  final String id;
  final String code;
  final String name;
  final String logoUrl;
  final String contactNo;
  final String email;
  final String address;
}

class MobileBranch {
  const MobileBranch({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.contactNo,
    required this.status,
    required this.isDefault,
  });

  factory MobileBranch.fromJson(Map<String, dynamic> json) => MobileBranch(
        id: _string(json['id']),
        code: _string(json['branch_code'] ?? json['branchCode']),
        name: _string(json['branch_name'] ?? json['branchName']),
        address: _string(json['address']),
        contactNo: _string(json['contact_no'] ?? json['contactNo']),
        status: _branchStatus(json),
        isDefault: json['is_default'] == true || json['isDefault'] == true,
      );

  final String id;
  final String code;
  final String name;
  final String address;
  final String contactNo;
  final String status;
  final bool isDefault;
}

class MobileBootstrapResponse {
  const MobileBootstrapResponse({
    required this.user,
    required this.organization,
    required this.branches,
    required this.defaultBranchId,
  });

  factory MobileBootstrapResponse.fromJson(Map<String, dynamic> json) {
    final payload = _payload(json);
    final branches = payload['branches'] ?? payload['assigned_branches'];
    return MobileBootstrapResponse(
      user: MobileUser.fromJson(_map(payload['user'])),
      organization: MobileOrganization.fromJson(
        _map(payload['organization']).isEmpty
            ? payload
            : _map(payload['organization']),
      ),
      branches: branches is List
          ? branches
              .whereType<Map<Object?, Object?>>()
              .map((item) => MobileBranch.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
      defaultBranchId: _nullableString(
        payload['default_branch_id'] ?? payload['defaultBranchId'],
      ),
    );
  }

  final MobileUser user;
  final MobileOrganization organization;
  final List<MobileBranch> branches;
  final String? defaultBranchId;
}

class SelectedBranchResponse {
  const SelectedBranchResponse({required this.branch});

  factory SelectedBranchResponse.fromJson(Map<String, dynamic> json) =>
      SelectedBranchResponse(
        branch: MobileBranch.fromJson(_map(json['selected_branch'])),
      );

  final MobileBranch branch;
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

Map<String, dynamic> _payload(Map<String, dynamic> json) {
  final nested = json['data'] ?? json['result'] ?? json['bootstrap'];
  return nested is Map ? Map<String, dynamic>.from(nested) : json;
}

String _branchStatus(Map<String, dynamic> json) {
  final status = _string(json['status']);
  if (status.isNotEmpty) return status.toUpperCase();
  if (json['is_active'] == false || json['isActive'] == false) {
    return 'INACTIVE';
  }
  return 'ACTIVE';
}

String _string(Object? value) => value?.toString() ?? '';

String? _nullableString(Object? value) {
  final result = _string(value);
  return result.isEmpty || result == 'null' ? null : result;
}
