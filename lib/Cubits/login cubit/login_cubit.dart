import 'package:bloc/bloc.dart';
import 'package:recipe_app/Api/login%20api/login_api_service.dart';
import 'package:recipe_app/Cubits/login%20cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginApiService loginApiService;

  LoginCubit(this.loginApiService) : super(LoginInitial());

  Future<void> loginUser(String email, String password) async {
    emit(LoginLoading());
    try {
      final result =
          await loginApiService.loginUser(email: email, password: password);

      if (result['success']) {
        emit(LoginSuccess(result['userId']));
      } else {
        emit(LoginFailure(result['error']));
      }
    } catch (e) {
      emit(LoginFailure("Failed to connect to the server: $e"));
    }
  }
}
