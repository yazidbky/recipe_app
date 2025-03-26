import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:recipe_app/Api/upload%20recipe%20api/upload_recipe_api_service.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  final RecipeApiService _apiService;

  UploadCubit(this._apiService) : super(UploadInitial());

  Future<void> uploadRecipe(
    String title,
    String description,
    List<String> ingredients, // Ingredients as a comma-separated string
    String instructions,
    String category,
    String time,
    File imageFile,
    String token,
  ) async {
    try {
      emit(UploadInProgress());

      final response = await _apiService.createRecipe(
        title: title,
        description: description,
        ingredients: ingredients, // Pass as list of strings
        instructions: instructions,
        category: category,
        time: time,
        imageFile: imageFile,
        token: token,
      );

      if (response['success']) {
        emit(UploadSuccess());
      } else {
        print('Error on the response: ${response['error']}');
        emit(UploadFailure(response['error']));
      }
    } catch (e) {
      print('Error of catch  : $e');
      emit(UploadFailure(e.toString()));
    }
  }
}
