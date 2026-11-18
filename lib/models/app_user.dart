import 'package:equatable/equatable.dart';

enum UserRole{
  admin,
  superAdmin,
}

class AppUser extends Equatable{
  final String userCode;
  final String userName;
  final UserRole userRole;

  const AppUser({required this.userCode, required this.userName, required this.userRole});

  bool get isAdmin => userRole == UserRole.admin;
  bool get isSuperAdmin => userRole == UserRole.superAdmin;

    @override
  List<Object?> get props => [
        userCode,
        userName,
        userRole,
      ];
}