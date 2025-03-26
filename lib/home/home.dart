import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_state.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_state.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_cubit.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_state.dart';
import 'package:recipe_app/Main%20Classes/search_screen.dart';
import 'package:recipe_app/components/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  StreamSubscription? _uploadSubscription;
  StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _fetchRecipes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Setup subscriptions
    _uploadSubscription?.cancel();
    _updateSubscription?.cancel();

    _uploadSubscription = context.read<UploadCubit>().stream.listen((state) {
      if (state is UploadSuccess && mounted) {
        _fetchRecipes();
      }
    });

    _updateSubscription =
        context.read<UpdateRecipeCubit>().stream.listen((state) {
      if (state is UpdateRecipeSuccess && mounted) {
        _fetchRecipes();
      }
    });
  }

  @override
  void dispose() {
    _uploadSubscription?.cancel();
    _updateSubscription?.cancel();
    super.dispose();
  }

  void _navigateToSearchScreen() async {
    final result = await Navigator.of(context).push(_createSearchScreenRoute());
    if (result == true && mounted) {
      _fetchRecipes();
    }
  }

  PageRouteBuilder _createSearchScreenRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SearchScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  void _onCategorySelected(int index) {
    if (!mounted) return;

    setState(() {
      _selectedCategory = index;
    });

    final category = index == 0 ? null : (index == 1 ? 'Food' : 'Drinks');
    context.read<GetRecipeCubit>().fetchRecipes(category: category);
  }

  void _fetchRecipes() {
    final category = _selectedCategory == 0
        ? null
        : (_selectedCategory == 1 ? 'Food' : 'Drinks');
    context.read<GetRecipeCubit>().fetchRecipes(category: category);
  }

  Future<void> _refreshRecipes() async {
    final category = _selectedCategory == 0
        ? null
        : (_selectedCategory == 1 ? 'Food' : 'Drinks');
    await context.read<GetRecipeCubit>().fetchRecipes(category: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: GestureDetector(
          onTap: _navigateToSearchScreen,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                ),
                const SizedBox(width: 8),
                Text("Search",
                    style: TextStyle(
                      fontSize: 16,
                    )),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecipes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _categoryButton("All", 0),
                  _categoryButton("Food", 1),
                  _categoryButton("Drinks", 2),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<GetRecipeCubit, RecipeState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (state is RecipeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RecipeError) {
                    return Center(child: Text(state.error));
                  } else if (state is RecipeLoaded) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        itemCount: state.recipes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: state.recipes[index],
                            contextId: 'home',
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: Text("No recipes found."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String text, int index) {
    return GestureDetector(
      onTap: () => _onCategorySelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedCategory == index ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedCategory == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
