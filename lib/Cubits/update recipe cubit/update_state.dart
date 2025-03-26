abstract class UpdateRecipeState {}

class UpdateRecipeInitial extends UpdateRecipeState {}

class UpdateRecipeLoading extends UpdateRecipeState {}

class UpdateRecipeSuccess extends UpdateRecipeState {
  final Map<String, dynamic> recipe;

  UpdateRecipeSuccess(this.recipe);
}

class UpdateRecipeFailure extends UpdateRecipeState {
  final String error;

  UpdateRecipeFailure(this.error);
}
