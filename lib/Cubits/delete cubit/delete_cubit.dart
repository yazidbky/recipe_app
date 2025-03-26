import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/delete%20recipes/delete_recipes_service.dart';
import 'package:recipe_app/Cubits/delete%20cubit/delete_state.dart';

class DeleteRecipeCubit extends Cubit<DeleteRecipeState> {
  final DeleteRecipeApiService _apiService;

  DeleteRecipeCubit(this._apiService) : super(DeleteRecipeInitial());

  Future<void> deleteRecipe(String recipeId) async {
    emit(DeleteRecipeLoading());
    try {
      final response = await _apiService.deleteRecipe(recipeId);
      if (response['success']) {
        emit(DeleteRecipeSuccess());
      } else {
        emit(DeleteRecipeFailure(response['error']));
      }
    } catch (e) {
      emit(DeleteRecipeFailure("Unexpected error: $e"));
    }
  }
}
