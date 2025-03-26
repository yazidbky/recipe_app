import 'package:dio/dio.dart';
import 'package:recipe_app/constants/base_url.dart';
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';

class UserApiService {
  static const String userEndpoint = '/api/users';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final token = await getToken();
      final response = await _dio.get(
        '$baseUrl$userEndpoint/$userId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "user": response.data,
        };
      }
      return {"success": false, "error": "Failed to fetch user"};
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data['message'] ?? "Failed to fetch user"
      };
    } catch (e) {
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }
}
