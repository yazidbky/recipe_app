import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';
import 'package:recipe_app/constants/base_url.dart';

class UpdateRecipeApiService {
  Future<Map<String, dynamic>> updateRecipe({
    required String recipeId,
    required String title,
    required String description,
    required List<String> ingredients,
    required String instructions,
    required String category,
    required String time,
    File? imageFile,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication token missing"};
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json'; // Explicitly request JSON

      // Add fields (unchanged)
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['time'] = time;
      request.fields['instructions'] = instructions;

      for (int i = 0; i < ingredients.length; i++) {
        request.fields['ingredients[$i]'] = ingredients[i];
      }

      if (imageFile != null) {
        final fileStream = http.ByteStream(imageFile.openRead());
        final fileLength = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image',
          fileStream,
          fileLength,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Improved response handling
      if (response.statusCode == 200) {
        try {
          // Try to parse as JSON
          final jsonResponse = json.decode(responseBody);
          return {
            "success": true,
            "recipe": jsonResponse is Map ? jsonResponse : {"id": recipeId}
          };
        } catch (e) {
          // If not JSON, treat as success with minimal response
          return {
            "success": true,
            "recipe": {"id": recipeId, "message": "Recipe updated successfully"}
          };
        }
      } else {
        return {
          "success": false,
          "error": _parseError(responseBody, response.statusCode)
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Network error: Please check your connection"
      };
    }
  }

  String _parseError(String responseBody, int statusCode) {
    try {
      final jsonError = json.decode(responseBody);
      return jsonError['message'] ??
          jsonError['error'] ??
          'Update failed (Status $statusCode)';
    } catch (e) {
      return responseBody.isNotEmpty
          ? responseBody
          : 'Update failed (Status $statusCode)';
    }
  }
}
