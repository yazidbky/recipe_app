abstract class RecipeState {}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<dynamic> recipes;

  RecipeLoaded(this.recipes);
}

class RecipeError extends RecipeState {
  final String error;

  RecipeError(this.error);
}
