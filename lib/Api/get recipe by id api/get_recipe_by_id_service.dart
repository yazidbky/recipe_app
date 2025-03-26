import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/constants/base_url.dart';

class GetRecipeByIdApiService {
  static const String recipesEndpoint = '/api/recipes';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getRecipeById(String id) async {
    try {
      final String url = '$baseUrl$recipesEndpoint/$id';
      final token = await _getToken();

      final response = await _dio.get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        return {"success": true, "recipe": response.data};
      }

      return {"success": false, "error": "Failed to fetch recipe."};
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data['message'] ?? "Failed to fetch recipe."
      };
    } catch (e) {
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
