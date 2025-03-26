import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/registre%20api/registre_api_service.dart';
import 'package:recipe_app/Cubits/registre%20cubit/registre_state.dart';

class RegistreCubit extends Cubit<RegistreState> {
  final RegistreApiService registreApiService;

  RegistreCubit(this.registreApiService) : super(RegistreInitial());

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(RegistreLoading());
    try {
      final result = await registreApiService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (result['success']) {
        emit(RegistreSuccess(result['message']));
      } else {
        emit(RegistreFailure(result['error']));
      }
    } catch (e) {
      emit(RegistreFailure("Failed to connect to the server: $e"));
    }
  }
}
