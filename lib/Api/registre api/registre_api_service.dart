import 'package:dio/dio.dart';
import 'package:recipe_app/Api/registre%20api/registre_json.dart';
import 'package:recipe_app/constants/base_url.dart';

class RegistreApiService {
  static const String registerUrl = '$baseUrl/api/users/register';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    User user = User(name: name, email: email, password: password);
    final Map<String, dynamic> body = user.toMap();

    try {
      final response = await _dio.post(
        registerUrl,
        data: body, // No need for json.encode with Dio
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.data}');

      if (response.statusCode == 201) {
        User registeredUser = User.fromJson(response.data);
        return {
          "success": true,
          "message": "User registered successfully",
          "user": registeredUser
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {"success": false, "error": "Email already in use"};
      } else if (e.response?.statusCode == 500) {
        return {
          "success": false,
          "error": "Server error, please try again later."
        };
      } else {
        return {
          "success": false,
          "error": e.response?.data["message"] ?? "An error occurred"
        };
      }
    } catch (e) {
      print("Unexpected error: $e");
      return {"success": false, "error": "Failed to connect to the server."};
    }

    return {"success": false, "error": "Something went wrong"};
  }
}
