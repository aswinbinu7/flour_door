import 'package:shared_preferences/shared_preferences.dart';
import '../Database/database_helper.dart';
import '../Model/UserModel.dart';

class AuthService {
  final DbHelper _dbHelper = DbHelper();

  Future<AuthStatus> login(String username, String password) async {
    try {
      UserModel? user = await _dbHelper.getLoginUser(username, password);
      if (user != null) {
        // Login successful, store user_id in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.user_id!);  // Assuming user_id is not null here
        return AuthStatus.success;
      } else {
        // Login failed
        return AuthStatus.failure;
      }
    } catch (e) {
      print("Error during login: $e");
      return AuthStatus.failure;
    }
  }

  Future<void> logout() async {
    try {
      // Clear user_id from SharedPreferences during logout
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}

enum AuthStatus {
  success,
  failure,
}
