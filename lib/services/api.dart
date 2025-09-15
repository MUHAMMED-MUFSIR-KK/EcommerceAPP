import 'package:dio/dio.dart';

class Api {
  late final Dio dio;
  static const String baseUrl = "http://172.19.224.1:3000/api";

  Api() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> userRegister(
    String username,
    String password,
    String email,
  ) async {
    try {
      print("userRegister.....................");
      final response = await dio.post(
        "/auth/register",
        data: {"username": username, "email": email, "password": password},
      );
      print("$response ");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": "Registration successful"};
      } else {
        return {"success": false, "message": "Registration failed"};
      }
    } catch (e) {
      print("error $e");
      return {"success": false, "message": "Network error: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> userLogin(String email, String password) async {
    try {
      print("userLogin .....................");
      print("Attempting to connect to: $baseUrl/auth/login");
      print(
        "Request data: {\"email\": \"$email\", \"password\": \"[HIDDEN]\"}",
      );

      final response = await dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );
      print("Response received: ${response.statusCode}");
      print("Response data: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        return {"success": false, "message": "Login failed"};
      }
    } catch (e) {
      print("error $e");
      return {"success": false, "message": "Login failed: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print("forgotPassword .....................");
      print("Attempting to connect to: $baseUrl/auth/forgot-password");
      print("Request data: {\"email\": \"$email\"}");

      final response = await dio.post(
        "/auth/forgot-password",
        data: {"email": email},
      );
      print("Response received: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ??
            {
              "success": true,
              "message": "Password reset link sent to your email",
            };
      } else {
        return {"success": false, "message": "Failed to send reset link"};
      }
    } catch (e) {
      print("error $e");
      return {
        "success": false,
        "message": "Failed to send reset link: ${e.toString()}",
      };
    }
  }
}
