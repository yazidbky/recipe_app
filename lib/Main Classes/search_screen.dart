import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_cubit.dart';
import 'package:recipe_app/Cubits/get%20recipe%20cubit/get_recipe_state.dart';
import 'package:recipe_app/components/recipe_card.dart';
import 'package:recipe_app/constants/colors.dart';
import 'package:recipe_app/components/custom_text_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  double _cookingDuration = 30; // Default slider position

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Text("Add a Filter",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),

                    // Category Filter
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: ["All", "Food", "Drinks"].map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                            showCheckmark: false,
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedCategory = category;
                                // Update search bar text
                              });
                            },
                            selectedColor: primaryColor,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: _selectedCategory == category
                                  ? primaryColor
                                  : Colors.grey[400] ?? Colors.grey,
                            ),
                            labelStyle: TextStyle(
                              color: _selectedCategory == category
                                  ? Colors.white
                                  : Colors.grey[400],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),

                    // Cooking Duration Filter
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cooking Duration (in minutes)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("<10",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                        Text("${_cookingDuration.toInt()}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor)),
                        Text(">60",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: primaryColor,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      ),
                      child: Slider(
                        value: _cookingDuration,
                        min: 10,
                        max: 60,
                        divisions: 5,
                        onChanged: (value) {
                          setModalState(() {
                            _cookingDuration = value;
                          });
                        },
                      ),
                    ),

                    // Buttons
                    _cancelDoneButtons(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _cancelDoneButtons() {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.all(15),
            color: Colors.grey[200],
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: MaterialButton(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.all(15),
            color: primaryColor,
            onPressed: () {
              Navigator.pop(context);
              _performSearch(
                  _searchController.text); // Apply filters and search
            },
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _performSearch(String query) {
    // Fetch recipes based on the search query and filters
    context.read<GetRecipeCubit>().fetchRecipes(
          search: query,
          category: _selectedCategory == "All" ? null : _selectedCategory,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
            context
                .read<GetRecipeCubit>()
                .fetchRecipes(search: "", category: "All"); // Reset search

            _searchController.clear();
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: CustomTextField(
                onSubmitted: (query) {
                  _performSearch(query);
                },
                controller: _searchController,
                hintText: "Search for recipes",
                suffixIcon: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch(""); // Clear the search results
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list_outlined, color: Colors.black),
              onPressed: _showFilterBottomSheet,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Search suggestions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 20,
              children:
                  ["Sushi", "Pasta", "Salad", "Dessert"].map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = suggestion;
                    _performSearch(suggestion); // Perform search
                  },
                  child: Chip(
                    label: Text(suggestion),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<GetRecipeCubit, RecipeState>(
                builder: (context, state) {
                  if (state is RecipeLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is RecipeError) {
                    return Center(child: Text(state.error));
                  } else if (state is RecipeLoaded) {
                    return GridView.builder(
                      itemCount: state.recipes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return RecipeCard(recipe: state.recipes[index]);
                      },
                    );
                  } else {
                    return Center(child: Text("No recipes found."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
