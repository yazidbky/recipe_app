abstract class UserRecipesState {}

class UserRecipesInitial extends UserRecipesState {}

class UserRecipesLoading extends UserRecipesState {}

class UserRecipesLoaded extends UserRecipesState {
  final List<dynamic> recipes;
  final bool showLiked;
  final Map<String, dynamic>? userData;

  UserRecipesLoaded(this.recipes, {this.userData, this.showLiked = false});
  int get recipeCount => recipes.length;

  UserRecipesLoaded copyWith({
    List<dynamic>? recipes,
    bool? showLiked,
    Map<String, dynamic>? userData,
  }) {
    return UserRecipesLoaded(
      recipes ?? this.recipes,
      userData: userData ?? this.userData,
      showLiked: showLiked ?? this.showLiked,
    );
  }
}

class UserRecipesError extends UserRecipesState {
  final String error;

  UserRecipesError(this.error);
}
