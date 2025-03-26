import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/constants/base_url.dart';

class GetRecipeApiService {
  static const String recipesEndpoint = '/api/recipes';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getRecipes({
    String? search,
    String? category,
  }) async {
    try {
      final String url = '$baseUrl$recipesEndpoint';
      final token = await _getToken();

      final response = await _dio.get(
        url,
        queryParameters: {
          if (search != null) 'search': search,
          if (category != null) 'category': category,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        return {"success": true, "recipes": response.data};
      }

      return {"success": false, "error": "Failed to fetch recipes."};
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data['message'] ?? "Failed to fetch recipes."
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
