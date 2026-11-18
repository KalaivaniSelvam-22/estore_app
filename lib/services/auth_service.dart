import 'package:estore_app/core/errors/auth_exception.dart';
import 'package:estore_app/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userCodeKey = 'session_user_code';
  static const String _expiryKey = 'session_expiry';
  static const Duration sessionDuration = Duration(hours: 24);
  AppUser login({required String userCode, required String password}) {
    final code = userCode.trim();
    if (code.isEmpty || password.isEmpty) {
      throw const AuthException(
        message: 'Please enter your user code and password to proceed further.',
      );
    }
    switch (code) {
      case '1001':
        if (password == 'admin') {
          return const AppUser(
            userCode: '1001',
            userName: 'Admin',
            userRole: UserRole.admin,
          );
        }
        break;
      case '1002':
        if (password == 'superadmin') {
          return const AppUser(
            userCode: '1002',
            userName: 'Super Admin',
            userRole: UserRole.superAdmin,
          );
        }
    }
    throw const AuthException(message: 'Invalid user code or password');
  }

  Future<void> saveSession(AppUser user) async {
    final preferences = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(sessionDuration).microsecondsSinceEpoch;
    await preferences.setString(_userCodeKey, user.userCode);
    await preferences.setInt(_expiryKey, expiry);
  }

  Future<AppUser?> restoreSession() async {
    final preference = await SharedPreferences.getInstance();
    final userCode = preference.getString(_userCodeKey);
    final expiry = preference.getInt(_expiryKey);
    if (userCode == null || expiry == null) {
      await clearSession();
      return null;
    }
    if (DateTime.now().microsecondsSinceEpoch > expiry) {
      await clearSession();
      return null;
    }
    switch (userCode) {
      case '1001':
        return const AppUser(
          userCode: '1001',
          userName: 'Admin',
          userRole: UserRole.admin,
        );
      case '1002':
        return const AppUser(
          userCode: '1002',
          userName: 'Super Admin',
          userRole: UserRole.superAdmin,
        );
      default:
        await clearSession();
        return null;
    }
  }

  Future<void> clearSession() async {
    final preference = await SharedPreferences.getInstance();
    await preference.remove(_userCodeKey);
    await preference.remove(_expiryKey);
  }
}
