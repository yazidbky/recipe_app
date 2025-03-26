import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20user%20cubit/get_recipe_by_user_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20user%20cubit/get_recipe_by_user_state.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_cubit.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_state.dart';
import 'package:recipe_app/Cubits/refresh%20cubit/refresh_cubit.dart';
import 'package:recipe_app/Cubits/theme%20cubit/theme_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_state.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_cubit.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_state.dart';
import 'package:recipe_app/components/recipe_card.dart';
import 'package:recipe_app/constants/colors.dart';
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';
import 'package:recipe_app/start/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  void handleLogout(BuildContext context) async {
    await logoutUser();
    await clearUserId();
    context.read<UserRecipesCubit>().reset();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    final completer = Completer();
    try {
      await Future.wait([
        context.read<UserCubit>().fetchUser(userId),
        context.read<UserRecipesCubit>().fetchRecipesByUser(userId),
      ]);
      completer.complete();
    } catch (e) {
      completer.complete();
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(context);
    });

    return MultiBlocListener(
      listeners: [
        BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserInitial ||
                (state is UserLoaded && state.user['_id'] != userId)) {
              context.read<UserCubit>().fetchUser(userId);
            }
          },
        ),
        BlocListener<UploadCubit, UploadState>(
          listener: (context, state) {
            if (state is UploadSuccess) {
              _refreshData(context);
            }
          },
        ),
        BlocListener<UpdateRecipeCubit, UpdateRecipeState>(
          listener: (context, state) {
            if (state is UpdateRecipeSuccess) {
              _refreshData(context);
            }
          },
        ),
        BlocListener<RecipeRefreshCubit, void>(
          listener: (context, _) {
            _refreshData(context);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => handleLogout(context),
            ),
            IconButton(
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: Icon(
                context.watch<ThemeCubit>().state.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshData(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          AssetImage('assets/images/Onboarding.jpg'),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<UserCubit, UserState>(
                      buildWhen: (previous, current) {
                        return previous != current ||
                            userId !=
                                (current is UserLoaded
                                    ? current.user['_id']
                                    : null);
                      },
                      builder: (context, state) {
                        if (state is UserLoaded) {
                          return Text(
                            state.user['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (state is UserError) {
                          return const Text(
                            "Error loading name",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        if (state is! UserLoading) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<UserCubit>().fetchUser(userId);
                          });
                        }
                        return const Text(
                          "...Loading",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocBuilder<UserRecipesCubit, UserRecipesState>(
                          builder: (context, state) {
                            final recipeCount = state is UserRecipesLoaded
                                ? state.recipeCount.toString()
                                : "0";
                            return _buildStatItem(recipeCount, "Recipes");
                          },
                        ),
                        _buildStatItem("782", "Following"),
                        _buildStatItem("1.287", "Followers"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTabSection(),
                  ],
                ),
              ),
              BlocBuilder<UserRecipesCubit, UserRecipesState>(
                builder: (context, state) {
                  if (state is UserRecipesInitial) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context
                          .read<UserRecipesCubit>()
                          .fetchRecipesByUser(userId);
                    });
                  }
                  if (state is UserRecipesLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is UserRecipesError) {
                    return SliverFillRemaining(
                      child: Center(child: Text(state.error)),
                    );
                  } else if (state is UserRecipesLoaded) {
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getLikedRecipes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final recipes = state.showLiked
                            ? snapshot.data ?? []
                            : state.recipes;
                        if (recipes.isEmpty) {
                          return const SliverFillRemaining(
                            child: Center(child: Text("No recipes found.")),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => RecipeCard(
                                recipe: recipes[index],
                                contextId: 'profile',
                              ),
                              childCount: recipes.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SliverFillRemaining(
                      child: Center(child: Text("No recipes found.")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return BlocBuilder<UserRecipesCubit, UserRecipesState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<UserRecipesCubit>().toggleShowLiked(false);
                    context.read<UserRecipesCubit>().fetchRecipesByUser(userId);
                  },
                  child: _buildTabItem("Recipes",
                      state is UserRecipesLoaded ? !state.showLiked : true),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<UserRecipesCubit>().toggleShowLiked(true);
                  },
                  child: _buildTabItem("Liked",
                      state is UserRecipesLoaded ? state.showLiked : false),
                ),
              ],
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getLikedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_recipes');
    if (favoritesJson != null) {
      return List<Map<String, dynamic>>.from(
          json.decode(favoritesJson).map((x) => Map<String, dynamic>.from(x)));
    }
    return [];
  }

  Widget _buildTabItem(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 60,
              color: primaryColor,
            ),
        ],
      ),
    );
  }
}
