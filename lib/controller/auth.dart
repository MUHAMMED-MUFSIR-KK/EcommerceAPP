import 'package:flutter_application_1/services/api.dart';
import 'package:flutter_application_1/model/user_model.dart';

class AuthController {
  final Api _api = Api();

  Future<Map<String, dynamic>?> userRegister(
    String username,
    String password,
    String email,
  ) async {
    try {
      final response = await _api.userRegister(username, password, email);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<LoginResponse?> userLogin(String email, String password) async {
    try {
      final response = await _api.userLogin(email, password);
      return LoginResponse.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final response = await _api.forgotPassword(email);
      return response;
    } catch (e) {
      return null;
    }
  }
}
