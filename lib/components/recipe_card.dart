import 'package:flutter/material.dart';
import 'package:recipe_app/Main%20Classes/recipe_details.dart';
import 'package:recipe_app/Main%20Classes/upload_class.dart';
import 'package:recipe_app/shared%20prefrences/shared_prefrences.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String? userId; // Add this parameter
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? contextId;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.userId, // Make this optional
    this.onEdit,
    this.onDelete,
    this.contextId,
  });

  bool get isOwner {
    if (userId == null) return false;
    if (recipe['createdBy'] == null) return false;
    if (recipe['createdBy'] is String) {
      return recipe['createdBy'] == userId;
    }
    return recipe['createdBy']['_id'] == userId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final currentUserId = userId ?? await getUserId();
        if (currentUserId == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipeId: recipe['_id'],
              isOwner: isOwner ||
                  (recipe['createdBy'] != null &&
                      recipe['createdBy']['_id'] == currentUserId),
              userId: currentUserId,
              sourceContext: contextId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    child: // Remove any ClipRRect wrapping the Hero
                        Container(
                      color: Colors.red.withOpacity(0.3),
                      child: Hero(
                        tag:
                            'recipe-hero-${recipe['_id']}-${contextId ?? 'default'}',
                        // Use Material with explicit size and shape
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: Image.network(
                              recipe["image"],
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
                    )),
                if (isOwner)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          color: Colors.white,
                          onPressed: onEdit ??
                              () async {
                                // final userId = await getUserId();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeUploadScreen(
                                      initialData: recipe,
                                      userId: userId!,
                                    ),
                                  ),
                                );
                              },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          color: Colors.white,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    recipe["title"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "${recipe["category"]} • ${recipe["time"]} min",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
