// delete_recipe_cubit.dart
abstract class DeleteRecipeState {}

class DeleteRecipeInitial extends DeleteRecipeState {}

class DeleteRecipeLoading extends DeleteRecipeState {}

class DeleteRecipeSuccess extends DeleteRecipeState {}

class DeleteRecipeFailure extends DeleteRecipeState {
  final String error;

  DeleteRecipeFailure(this.error);
}
