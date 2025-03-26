// delete_recipe_api_service.dart
import 'package:http/http.dart' as http;
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';
import 'package:recipe_app/constants/base_url.dart';

class DeleteRecipeApiService {
  Future<Map<String, dynamic>> deleteRecipe(String recipeId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "error": "Failed to delete recipe. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }
}
