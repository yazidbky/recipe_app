import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/get%20recipes%20api/get_recipe_services.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_state.dart';

class GetRecipeCubit extends Cubit<RecipeState> {
  final GetRecipeApiService _apiService;

  GetRecipeCubit(this._apiService) : super(RecipeInitial());

  Future<void> refreshRecipes({String? category}) async {
    emit(RecipeLoading());
    await fetchRecipes(category: category);
  }

  Future<void> fetchRecipes({String? search, String? category}) async {
    emit(RecipeLoading());

    try {
      final response = await _apiService.getRecipes(
        search: search,
        category: category,
      );

      if (response['success']) {
        emit(RecipeLoaded(response['recipes']));
      } else {
        emit(RecipeError(response['error']));
      }
    } catch (e) {
      emit(RecipeError("Unexpected error: $e"));
    }
  }
}
