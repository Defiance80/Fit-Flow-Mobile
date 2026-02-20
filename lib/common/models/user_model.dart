import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/local_storage.dart';

class UserModel extends Model {
  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? emailVerifiedAt;
  final String? profile;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Role> roles;
  final num walletBalance;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.emailVerifiedAt,
    this.profile,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    required this.token,
    required this.walletBalance,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'email_verified_at': emailVerifiedAt,
      'profile': profile,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles.map((role) => role.toJson()).toList(),
      'token': token,
    };
  }

  @override
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json.require<int>('id'),
        walletBalance: json['wallet_balance'] is String
            ? num.parse(json['wallet_balance'])
            : json.optional<num>('wallet_balance') ?? 0,
        name: json.require<String>('name'),
        email: json.optional<String>('email'),
        mobile: json.optional<String>('mobile'),
        emailVerifiedAt: json.optional<String>('email_verified_at'),
        profile: json.optional<String>('profile'),
        type: json.optional<String>('type'),
        createdAt: DateTime.parse(json.require<String>('created_at')),
        updatedAt: DateTime.parse(json.require<String>('updated_at')),
        roles:
            json
                .optional<List>('roles')
                ?.map((roleJson) => Role.fromJson(roleJson))
                .toList() ??
            [],
        token: json.optional<String>('token') ?? LocalStorage.token ?? '',
      );
    } catch (e) {
      throw Exception('Failed to parse UserModel: $e');
    }
  }
}

class Role {
  final int id;
  final String name;
  final String guardName;

  Role({required this.id, required this.name, required this.guardName});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'guard_name': guardName};
  }

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      guardName: json['guard_name'],
    );
  }
}
