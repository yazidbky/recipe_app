import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Api/delete%20recipes/delete_recipes_service.dart';
import 'package:recipe_app/Api/get%20recipe%20by%20id%20api/get_recipe_by_id_service.dart';
import 'package:recipe_app/Api/get%20recipes%20api/get_recipe_services.dart';
import 'package:recipe_app/Api/get%20recipes%20by%20user/get_recipe_by_user_service.dart';
import 'package:recipe_app/Api/get%20user/get_user_service.dart';
import 'package:recipe_app/Api/login%20api/login_api_service.dart';
import 'package:recipe_app/Api/registre%20api/registre_api_service.dart';
import 'package:recipe_app/Api/update%20recipes/update_recipes_service.dart';
import 'package:recipe_app/Api/upload%20recipe%20api/upload_recipe_api_service.dart';
import 'package:recipe_app/Cubits/delete%20cubit/delete_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20id%20cubit/get_recipe_by_id_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20user%20cubit/get_recipe_by_user_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_cubit.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_cubit.dart';
import 'package:recipe_app/Cubits/login%20cubit/login_cubit.dart';
import 'package:recipe_app/Cubits/refresh%20cubit/refresh_cubit.dart';
import 'package:recipe_app/Cubits/registre%20cubit/registre_cubit.dart';
import 'package:recipe_app/Cubits/theme%20cubit/theme_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_cubit.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_cubit.dart';
import 'package:recipe_app/components/app_theme.dart';
import 'package:recipe_app/components/navigation_bar.dart';
import 'package:recipe_app/start/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  final String? userId = prefs.getString('user_id');
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(BlocProvider(
    create: (context) => ThemeCubit(),
    child: MyApp(
        isLoggedIn: token != null, userId: userId, isDarkMode: isDarkMode),
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;
  final bool isDarkMode;

  const MyApp(
      {super.key,
      required this.isLoggedIn,
      this.userId,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(LoginApiService()),
        ),
        BlocProvider(
          create: (context) => RegistreCubit(RegistreApiService()),
        ),
        BlocProvider(
          create: (context) => UploadCubit(
            RecipeApiService(),
          ),
        ),
        BlocProvider(
            create: (context) => GetRecipeCubit(GetRecipeApiService())),
        BlocProvider(
            create: (context) => RecipeDetailCubit(GetRecipeByIdApiService())),
        BlocProvider(
            create: (context) => UserRecipesCubit(UserRecipesApiService())),
        BlocProvider(
            create: (context) => UserRecipesCubit(UserRecipesApiService())),
        BlocProvider(
            create: (context) => UpdateRecipeCubit(UpdateRecipeApiService())),
        BlocProvider(
            create: (context) => DeleteRecipeCubit(DeleteRecipeApiService())),
        BlocProvider(create: (context) => UserCubit(UserApiService())),
        BlocProvider(create: (_) => RecipeRefreshCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: isLoggedIn ? NavBar(userId: userId!) : Login(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
