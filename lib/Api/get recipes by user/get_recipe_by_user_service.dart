import 'package:dio/dio.dart';
import 'package:recipe_app/constants/base_url.dart';
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';

class UserRecipesApiService {
  static const String recipesEndpoint = '/api/recipes';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getRecipesByUser(String userId) async {
    try {
      final String url = '$baseUrl$recipesEndpoint';
      final token = await getToken();

      final response = await _dio.get(
        url,
        queryParameters: {'userId': userId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      print('API Response: ${response.data}'); // Add debug print

      if (response.statusCode == 200) {
        // Ensure the response is a List
        if (response.data is List) {
          return {
            "success": true,
            "recipes": response.data,
          };
        }
        return {"success": false, "error": "Invalid data format"};
      }
      return {"success": false, "error": "Failed to fetch recipes"};
    } on DioException catch (e) {
      print('API Error: ${e.response?.data}');
      return {
        "success": false,
        "error": e.response?.data['message'] ?? "Failed to fetch recipes"
      };
    } catch (e) {
      print('Unexpected Error: $e');
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }
}
