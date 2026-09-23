class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isSuperAdmin,
    required this.organizationId,
    required this.organizationName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'].toString(),
        username: json['username']?.toString() ?? '',
        fullName: json['full_name']?.toString() ??
            json['fullName']?.toString() ??
            json['username']?.toString() ??
            '',
        role: json['role']?.toString() ?? 'STAFF',
        isSuperAdmin:
            json['is_super_admin'] == true || json['isSuperAdmin'] == true,
        organizationId: json['organization_id']?.toString() ??
            json['organizationId']?.toString() ??
            '',
        organizationName: json['organization_name']?.toString() ??
            json['organizationName']?.toString() ??
            json['organization']?.toString() ??
            '',
      );

  final String id;
  final String username;
  final String fullName;
  final String role;
  final bool isSuperAdmin;
  final String organizationId;
  final String organizationName;

  factory AuthUser.fromStoredJson(Map<String, dynamic> json) =>
      AuthUser.fromJson(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'role': role,
        'is_super_admin': isSuperAdmin,
        'organization_id': organizationId,
        'organization_name': organizationName,
      };
}

class LoginResponse {
  const LoginResponse({
    required this.user,
    required this.token,
    required this.tokenId,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'].toString(),
        tokenId: json['tokenId']?.toString() ?? '',
        expiresAt: json['expiresAt'] is num
            ? (json['expiresAt'] as num).toInt()
            : int.tryParse(json['expiresAt']?.toString() ?? ''),
      );

  final AuthUser user;
  final String token;
  final String tokenId;
  final int? expiresAt;
}
