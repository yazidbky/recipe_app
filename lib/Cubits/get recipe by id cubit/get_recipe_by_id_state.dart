abstract class RecipeDetailState {}

class RecipeDetailInitial extends RecipeDetailState {}

class RecipeDetailLoading extends RecipeDetailState {}

class RecipeDetailLoaded extends RecipeDetailState {
  final Map<String, dynamic> recipe;

  RecipeDetailLoaded(this.recipe);
}

class RecipeDetailError extends RecipeDetailState {
  final String error;

  RecipeDetailError(this.error);
}
