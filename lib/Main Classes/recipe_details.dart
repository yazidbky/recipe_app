import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/delete%20cubit/delete_cubit.dart';
import 'package:recipe_app/Cubits/delete%20cubit/delete_state.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20id%20cubit/get_recipe_by_id_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20by%20id%20cubit/get_recipe_by_id_state.dart';
import 'package:recipe_app/Main%20Classes/upload_class.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final bool isOwner;
  final String? userId;
  final String? sourceContext;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.isOwner = false,
    required this.userId,
    this.sourceContext,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;
  List<Map<String, dynamic>> favoriteRecipes = [];

  bool get isOwner {
    final recipe =
        (context.read<RecipeDetailCubit>().state as RecipeDetailLoaded).recipe;
    if (widget.userId == null) return false;
    if (recipe['createdBy'] == null) return false;
    if (recipe['createdBy'] is String) {
      return recipe['createdBy'] == widget.userId;
    }
    return recipe['createdBy']['_id'] == widget.userId;
  }

  @override
  void initState() {
    super.initState();
    context.read<RecipeDetailCubit>().fetchRecipeById(widget.recipeId);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_recipes');
    if (favoritesJson != null) {
      setState(() {
        favoriteRecipes = List<Map<String, dynamic>>.from(json
            .decode(favoritesJson)
            .map((x) => Map<String, dynamic>.from(x)));
        isFavorite =
            favoriteRecipes.any((recipe) => recipe['_id'] == widget.recipeId);
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      if (isFavorite) {
        favoriteRecipes.add(recipe);
      } else {
        favoriteRecipes.removeWhere((r) => r['_id'] == recipe['_id']);
      }
    });
    await prefs.setString(
      'favorite_recipes',
      json.encode(favoriteRecipes.map((x) => x).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          if (state is RecipeDetailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is RecipeDetailError) {
            return Center(child: Text(state.error));
          } else if (state is RecipeDetailLoaded) {
            final recipe = state.recipe;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Container(
                      color: Colors.red.withOpacity(0.3),
                      child: Hero(
                        tag:
                            'recipe-hero-${recipe['_id']}-${widget.sourceContext ?? 'default'}',
                        // Match the Material properties
                        child: Material(
                          type: MaterialType.transparency,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            child: Image.network(
                              recipe['image'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : Container(color: Colors.grey[300]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back),
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: IconButton(
                      onPressed: () => _toggleFavorite(recipe),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share),
                      color: Colors.black,
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.7,
                  maxChildSize: 1.0,
                  snap: true,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['title'],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${recipe['category']} • ${recipe['time']} min',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(recipe['image']),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '${recipe['createdBy']['name']}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Icon(Icons.favorite, color: Colors.red),
                                      Text(favoriteRecipes
                                          .where(
                                              (r) => r['_id'] == recipe['_id'])
                                          .length
                                          .toString()),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[300],
                                    height: 30,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(recipe['description'] as String),
                                  SizedBox(height: 16),
                                  Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[300],
                                    height: 30,
                                  ),
                                  Text(
                                    'Ingredients',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  ...(recipe['ingredients'] as List)
                                      .map<Widget>((ingredient) {
                                    return ListTile(
                                      leading: Icon(Icons.check_circle,
                                          color: Colors.green),
                                      title: Text(ingredient as String),
                                    );
                                  }).toList(),
                                  SizedBox(height: 16),
                                  Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[300],
                                    height: 30,
                                  ),
                                  Text(
                                    'Steps',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(recipe['instructions']),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      recipe['image'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (widget.isOwner)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text('Edit Recipe',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeUploadScreen(
                                    initialData: recipe,
                                    userId: widget.userId!,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.delete, color: Colors.white),
                            label: Text('Delete Recipe',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () =>
                                _confirmDelete(context, recipe['_id']),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: Text("No recipe found."));
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String recipeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe'),
        content: Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          BlocConsumer<DeleteRecipeCubit, DeleteRecipeState>(
            listener: (context, state) {
              if (state is DeleteRecipeSuccess) {
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recipe deleted successfully')),
                );
              }
              if (state is DeleteRecipeFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  context.read<DeleteRecipeCubit>().deleteRecipe(recipeId);
                },
                child: state is DeleteRecipeLoading
                    ? CircularProgressIndicator()
                    : Text('Delete', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
    );
  }
}
