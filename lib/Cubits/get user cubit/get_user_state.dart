abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, dynamic> user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  final String error;

  UserError(this.error);
}
