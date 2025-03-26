abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String userId;

  LoginSuccess(this.userId);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}
