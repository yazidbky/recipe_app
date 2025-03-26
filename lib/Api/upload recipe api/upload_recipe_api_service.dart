import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:recipe_app/constants/base_url.dart'; // For media type

class RecipeApiService {
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String description,
    required List<String> ingredients, // Comma-separated string
    required String instructions,
    required String category,
    required String time,
    required File imageFile,
    required String token,
  }) async {
    try {
      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/recipes'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      for (int i = 0; i < ingredients.length; i++) {
        request.fields['ingredients[$i]'] = ingredients[i];
      }
      request.fields['instructions'] = instructions;
      request.fields['category'] = category;
      request.fields['time'] = time;

      // Add image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image', // Field name for the file
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Adjust based on file type
      );

      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();

      // Read the response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return {"success": true, "recipe": responseBody};
      } else {
        return {"success": false, "error": "Failed to create recipe."};
      }
    } catch (e) {
      return {"success": false, "error": "Unexpected error: $e"};
    }
  }
}
