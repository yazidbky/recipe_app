import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/update%20recipes/update_recipes_service.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_state.dart';

class UpdateRecipeCubit extends Cubit<UpdateRecipeState> {
  final UpdateRecipeApiService _apiService;

  UpdateRecipeCubit(this._apiService) : super(UpdateRecipeInitial());

  Future<void> updateRecipe({
    required String recipeId,
    required String title,
    required String description,
    required List<String> ingredients,
    required String instructions,
    required String category,
    required String time,
    File? imageFile,
  }) async {
    emit(UpdateRecipeLoading());
    try {
      final response = await _apiService.updateRecipe(
        recipeId: recipeId,
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        category: category,
        time: time,
        imageFile: imageFile,
      );

      if (response['success']) {
        emit(UpdateRecipeSuccess(response['recipe']));
      } else {
        emit(UpdateRecipeFailure(response['error'] ?? 'Update failed'));
      }
    } catch (e) {
      emit(UpdateRecipeFailure("Unexpected error: ${e.toString()}"));
    }
  }
}
