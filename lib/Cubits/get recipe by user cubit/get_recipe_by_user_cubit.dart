import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/get%20recipes%20by%20user/get_recipe_by_user_service.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20user%20cubit/get_recipe_by_user_state.dart';

class UserRecipesCubit extends Cubit<UserRecipesState> {
  final UserRecipesApiService _apiService;
  bool showLiked = false;

  UserRecipesCubit(this._apiService) : super(UserRecipesInitial());
  void toggleShowLiked(bool value) {
    showLiked = value;
    if (state is UserRecipesLoaded) {
      emit((state as UserRecipesLoaded).copyWith(showLiked: value));
    }
  }

  Future<void> fetchRecipesByUser(String? userId) async {
    emit(UserRecipesLoading());
    print('Fetching recipes for user: $userId'); // Add this

    try {
      final response = await _apiService.getRecipesByUser(userId);
      print('API Response: $response'); // Add this

      if (response['success']) {
        print('Number of recipes: ${response['recipes'].length}'); // Add this
        emit(UserRecipesLoaded(response['recipes']));
      } else {
        print('API Error: ${response['error']}'); // Add this
        emit(UserRecipesError(response['error']));
      }
    } catch (e) {
      print('Cubit Error: $e'); // Add this
      emit(UserRecipesError("Unexpected error: ${e.toString()}"));
    }
  }

  void reset() {
    emit(UserRecipesInitial());
  }
}
