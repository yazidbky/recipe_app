import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/constants/base_url.dart';

class LoginApiService {
  static const String loginEndpoint = '/api/users/login';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final String url = '$baseUrl$loginEndpoint';

      final response = await _dio.post(
        url,
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseBody = response.data;

        // Check if required fields exist in the response
        if (!responseBody.containsKey('token') ||
            !responseBody.containsKey('userId')) {
          return {"success": false, "error": "Invalid response from server."};
        }

        final String token = responseBody['token'];
        final String userId = responseBody['userId'];

        // Store tokens asynchronously
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', userId);

        print("token  $token");

        return {
          "success": true,
          "message": "User logged in successfully",
          "token": token,
          "userId": userId,
        };
      }

      return {
        "success": false,
        "error": "Invalid credentials or server error."
      };
    } on DioException catch (e) {
      String errorMessage = "Failed to connect to the server.";

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Please try again.";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server is taking too long to respond.";
      } else if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? "Unexpected error.";
      }

      return {"success": false, "error": errorMessage};
    } catch (e) {
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
