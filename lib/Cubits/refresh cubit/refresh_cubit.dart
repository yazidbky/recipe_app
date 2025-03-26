import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeRefreshCubit extends Cubit<void> {
  RecipeRefreshCubit() : super(null);

  void refresh() => emit(null);
}
