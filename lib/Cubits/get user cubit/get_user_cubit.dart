import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/get%20user/get_user_service.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserApiService _apiService;

  UserCubit(this._apiService) : super(UserInitial());

  Future<void> fetchUser(String userId) async {
    if (state is UserLoading) return;

    emit(UserLoading());
    try {
      final response = await _apiService.getUser(userId);
      if (response['success']) {
        emit(UserLoaded(response['user']));
      } else {
        emit(UserError(response['error']));
        // Re-emit previous state after delay if available
        if (state is UserLoaded) {
          await Future.delayed(Duration(seconds: 2));
          emit(state);
        }
      }
    } catch (e) {
      emit(UserError("Failed to fetch user: ${e.toString()}"));
      // Re-emit previous state after delay if available
      if (state is UserLoaded) {
        await Future.delayed(Duration(seconds: 2));
        emit(state);
      }
    }
  }
}
