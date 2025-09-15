import 'package:flutter_application_1/services/api.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      print("AuthController: Calling API userLogin");
      final response = await _api.userLogin(email, password);
      print("AuthController: API response received: $response");

      // Check if response has success field and handle accordingly
      if (response.containsKey('success')) {
        if (response['success'] == true) {
          // Extract user data from the API response and convert to compatible format
          final userData = response['data']?['user'] ?? {};
          final token = response['data']?['token'] ?? '';

          final compatibleResponse = {
            'success': true,
            'message': response['message'] ?? 'Login successful',
            'data': {
              'token': token,
              'user': {
                'id':
                    userData['id']?.toString() ??
                    '1', // Convert number to string
                'createdAt':
                    userData['createdAt'] ?? DateTime.now().toIso8601String(),
                'updatedAt':
                    userData['updatedAt'] ?? DateTime.now().toIso8601String(),
                'username': userData['username'] ?? email.split('@')[0],
                'email': userData['email'] ?? email,
                'isActive': userData['isActive'] ?? true,
                'lastLogin': userData['lastLogin'],
              },
            },
            'timestamp':
                response['timestamp'] ?? DateTime.now().toIso8601String(),
          };

          print("AuthController: Compatible response: $compatibleResponse");

          try {
            final loginResponse = LoginResponse.fromJson(compatibleResponse);
            print(
              "AuthController: Parsed LoginResponse: success=${loginResponse.success}, message=${loginResponse.message}",
            );
            return loginResponse;
          } catch (parseError) {
            print(
              "AuthController: Error parsing compatible response: $parseError",
            );
            print(
              "AuthController: Compatible response was: $compatibleResponse",
            );
            return null;
          }
        } else {
          // Login failed
          final failedResponse = LoginResponse(
            success: false,
            message: response['message'] ?? 'Login failed',
            data: LoginData(
              token: '',
              user: User(
                id: '',
                createdAt: '',
                updatedAt: '',
                username: '',
                email: '',
                isActive: false,
              ),
            ),
            timestamp: DateTime.now().toIso8601String(),
          );
          return failedResponse;
        }
      } else {
        // Handle direct API response format: {user: {...}, message: "..."}
        if (response.containsKey('user') && response.containsKey('message')) {
          final userData = response['user'] ?? {};

          final compatibleResponse = {
            'success': true, // Assume success if we got user data
            'message': response['message'] ?? 'Login successful',
            'data': {
              'token': '', // API doesn't return token in this format
              'user': {
                'id': userData['id']?.toString() ?? '1',
                'createdAt':
                    userData['createdAt'] ?? DateTime.now().toIso8601String(),
                'updatedAt':
                    userData['updatedAt'] ??
                    userData['createdAt'] ??
                    DateTime.now().toIso8601String(),
                'username': userData['username'] ?? '',
                'email': userData['email'] ?? '',
                'isActive': true, // Default to true
                'lastLogin':
                    userData['lastLoginAt'], // Map lastLoginAt to lastLogin
              },
            },
            'timestamp': DateTime.now().toIso8601String(),
          };

          print("AuthController: Converted response: $compatibleResponse");

          try {
            final loginResponse = LoginResponse.fromJson(compatibleResponse);
            print(
              "AuthController: Parsed LoginResponse: success=${loginResponse.success}, message=${loginResponse.message}",
            );
            return loginResponse;
          } catch (parseError) {
            print(
              "AuthController: Error parsing converted response: $parseError",
            );
            return null;
          }
        } else {
          // Fallback: try direct parsing if structure matches expected format
          try {
            final loginResponse = LoginResponse.fromJson(response);
            print(
              "AuthController: Parsed LoginResponse: success=${loginResponse.success}, message=${loginResponse.message}",
            );
            return loginResponse;
          } catch (parseError) {
            print(
              "AuthController: Error parsing fallback response: $parseError",
            );
            print(
              "AuthController: Response structure: ${response.keys.toList()}",
            );
            return null;
          }
        }
      }
    } catch (e) {
      print("AuthController: Main catch block error: $e");
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

  // Method to get raw login response without parsing
  Future<Map<String, dynamic>?> getRawLoginResponse(
    String email,
    String password,
  ) async {
    try {
      print("AuthController: Getting raw login response");
      final response = await _api.userLogin(email, password);
      print("AuthController: Raw response: $response");
      return response;
    } catch (e) {
      print("AuthController: Error getting raw response: $e");
      return null;
    }
  }

  // Method to save login response to local storage
  Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the entire response
      await prefs.setString('login_response', jsonEncode(response));

      // Save individual useful fields
      if (response['data'] != null) {
        final data = response['data'];
        if (data['token'] != null) {
          await prefs.setString('auth_token', data['token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user_data', jsonEncode(data['user']));
        }
      }

      // Save login timestamp
      await prefs.setString(
        'login_timestamp',
        DateTime.now().toIso8601String(),
      );

      print("AuthController: Login response saved successfully");
    } catch (e) {
      print("AuthController: Error saving login response: $e");
    }
  }

  // Method to get saved login response
  Future<Map<String, dynamic>?> getSavedLoginResponse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responseString = prefs.getString('login_response');
      if (responseString != null) {
        return jsonDecode(responseString);
      }
      return null;
    } catch (e) {
      print("AuthController: Error getting saved login response: $e");
      return null;
    }
  }

  // Method to get saved auth token
  Future<String?> getSavedAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print("AuthController: Error getting saved auth token: $e");
      return null;
    }
  }

  // Method to get saved user data
  Future<Map<String, dynamic>?> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      print("AuthController: Error getting saved user data: $e");
      return null;
    }
  }

  // Method to get user profile info
  Future<Map<String, String>> getUserProfile() async {
    try {
      final userData = await getSavedUserData();
      if (userData != null) {
        return {
          'username': userData['username']?.toString() ?? 'Unknown User',
          'email': userData['email']?.toString() ?? 'No Email',
          'id': userData['id']?.toString() ?? '0',
        };
      }
      return {'username': 'Unknown User', 'email': 'No Email', 'id': '0'};
    } catch (e) {
      print("AuthController: Error getting user profile: $e");
      return {'username': 'Unknown User', 'email': 'No Email', 'id': '0'};
    }
  }

  // Method to clear saved login data
  Future<void> clearSavedLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('login_response');
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('login_timestamp');
      print("AuthController: Login data cleared successfully");
    } catch (e) {
      print("AuthController: Error clearing login data: $e");
    }
  }
}
