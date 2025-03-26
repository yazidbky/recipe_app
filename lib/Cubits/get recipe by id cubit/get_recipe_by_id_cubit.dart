import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/get%20recipe%20by%20id%20api/get_recipe_by_id_service.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20id%20cubit/get_recipe_by_id_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final GetRecipeByIdApiService _apiService;

  RecipeDetailCubit(this._apiService) : super(RecipeDetailInitial());

  Future<void> fetchRecipeById(String id) async {
    emit(RecipeDetailLoading());

    try {
      final response = await _apiService.getRecipeById(id);

      if (response['success']) {
        emit(RecipeDetailLoaded(response['recipe']));
      } else {
        emit(RecipeDetailError(response['error']));
      }
    } catch (e) {
      emit(RecipeDetailError("Unexpected error: $e"));
    }
  }
}
