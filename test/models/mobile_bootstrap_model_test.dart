import 'package:cocoper_operations/app/models/mobile/mobile_bootstrap_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses organization, nullable user fields, branches, and default', () {
    final response = MobileBootstrapResponse.fromJson({
      'success': true,
      'user': {
        'id': 'USR-1',
        'username': 'bunny',
        'full_name': null,
        'email': null,
        'role': 'Admin',
      },
      'organization': {
        'id': 'ORG-1',
        'organization_name': 'COCOPER',
      },
      'branches': [
        {
          'id': 'BR-1',
          'branch_code': null,
          'branch_name': 'Main',
          'status': 'ACTIVE',
          'is_default': true,
        },
        {
          'id': 'BR-2',
          'branch_name': 'Yard',
          'status': 'ACTIVE',
        },
      ],
      'default_branch_id': 'BR-1',
    });

    expect(response.organization.name, 'COCOPER');
    expect(response.user.fullName, isEmpty);
    expect(response.user.email, isEmpty);
    expect(response.branches, hasLength(2));
    expect(response.branches.first.code, isEmpty);
    expect(response.defaultBranchId, 'BR-1');
  });

  test('parses wrapped bootstrap responses and defaults missing status active',
      () {
    final response = MobileBootstrapResponse.fromJson({
      'success': true,
      'data': {
        'user': {'id': 'USR-1'},
        'organization': {'id': 'ORG-1', 'organization_name': 'COCOPER'},
        'assigned_branches': [
          {'id': 'BR-1', 'branch_name': 'Main'},
        ],
        'default_branch_id': null,
      },
    });

    expect(response.branches.single.status, 'ACTIVE');
    expect(response.defaultBranchId, isNull);
  });
}
