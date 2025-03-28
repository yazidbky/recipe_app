import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/get%20user%20cubit/get_user_cubit.dart';
import 'package:recipe_app/Cubits/refresh%20cubit/refresh_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_cubit.dart';
import 'package:recipe_app/Cubits/update%20recipe%20cubit/update_state.dart';
import 'package:recipe_app/components/upload_success_dialog.dart';
import 'package:recipe_app/constants/colors.dart';
import 'package:recipe_app/components/custom_text_field.dart';
import 'package:recipe_app/components/upload_files_card.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_cubit.dart';
import 'package:recipe_app/Cubits/upload%20cubit/upload_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class RecipeUploadScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? userId;
  const RecipeUploadScreen({super.key, this.initialData, this.userId});

  @override
  State<RecipeUploadScreen> createState() => _RecipeUploadScreenState();
}

class _RecipeUploadScreenState extends State<RecipeUploadScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController instructionsController;
  late List<TextEditingController> ingredientControllers;
  late String selectedCategory;
  late String cookingDuration;
  XFile? selectedImage;
  String? existingImageUrl;
  bool isEditing = false;

  final List<String> categories = ["Food", "Drinks"];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    isEditing = widget.initialData != null;

    if (isEditing) {
      titleController =
          TextEditingController(text: widget.initialData!['title']);
      descriptionController =
          TextEditingController(text: widget.initialData!['description']);
      instructionsController =
          TextEditingController(text: widget.initialData!['instructions']);
      selectedCategory = widget.initialData!['category'];
      cookingDuration = widget.initialData!['time'].toString();
      existingImageUrl = widget.initialData!['image'];

      ingredientControllers = (widget.initialData!['ingredients'] as List)
          .map((ingredient) => TextEditingController(text: ingredient))
          .toList();
    } else {
      titleController = TextEditingController();
      descriptionController = TextEditingController();
      instructionsController = TextEditingController();
      selectedCategory = "Food";
      cookingDuration = '30';
      ingredientControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    for (var controller in ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UploadCubit, UploadState>(
          listener: (context, state) {
            if (state is UploadSuccess) {
              context.read<UserCubit>().fetchUser(widget.userId);
              context.read<RecipeRefreshCubit>().refresh();
              context.read<UserCubit>().fetchUser(widget.userId);

              showDialog(
                context: context,
                barrierDismissible: false, // User must tap button to close
                builder: (BuildContext context) {
                  return UploadSuccessDialog(
                    userId: widget.userId,
                    message: "Recipe uploaded successfully!",
                    title: "Success",
                  );
                },
              );
            } else if (state is UploadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
        ),
        BlocListener<UpdateRecipeCubit, UpdateRecipeState>(
          listener: (context, state) {
            if (state is UpdateRecipeSuccess) {
              context.read<UserCubit>().fetchUser(widget.userId);
              context.read<RecipeRefreshCubit>().refresh();
              context.read<UserCubit>().fetchUser(widget.userId);
              showDialog(
                context: context,
                barrierDismissible: false, // User must tap button to close
                builder: (BuildContext context) {
                  return UploadSuccessDialog(
                    userId: widget.userId,
                    message: "Recipe updated successfully!",
                    title: "Success",
                  );
                },
              );
            } else if (state is UpdateRecipeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${currentStep + 1}/2",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: currentStep == 0 ? _buildStepOne() : _buildStepTwo(),
      ),
    );
  }

  Widget _buildStepOne() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagePicker(),
            SizedBox(height: 16),
            Text("Food Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CustomTextField(
                controller: titleController, hintText: 'Enter food name'),
            SizedBox(height: 16),
            Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CustomTextField(
                controller: descriptionController,
                hintText: 'Tell a little about your food',
                maxLines: 3,
                borderRadius: 8),
            SizedBox(height: 16),
            _categoryDropdown(),
            SizedBox(height: 16),
            _cookingDurationSlider(),
            SizedBox(height: 30),
            _nextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: ingredientControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return ListTile(
                  key: ValueKey(index),
                  title: CustomTextField(
                    controller: ingredientControllers[index],
                    hintText: 'Enter ingredient',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ),
                );
              }).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = ingredientControllers.removeAt(oldIndex);
                  ingredientControllers.insert(newIndex, item);
                });
              },
            ),
            SizedBox(height: 16),
            _addIngredientButton(),
            SizedBox(height: 16),
            Text("Steps",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CustomTextField(
              controller: instructionsController,
              hintText: 'Tell a little about your food',
              maxLines: 3,
              borderRadius: 8,
            ),
            SizedBox(height: 16),
            _backNextButtons(),
          ],
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePicker() {
    return UploadCard(
      drgaFile: selectedImage == null
          ? "Drag and drop file here"
          : "Uploaded: ${selectedImage!.name}",
      onTap: _pickImage,
      child: selectedImage != null
          ? Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(selectedImage!.path),
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.height * 0.25,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      onPressed: _removeImage,
                      icon: Icon(
                        Icons.highlight_remove,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${selectedImage!.name} - ${(File(selectedImage!.path).lengthSync() / 1024).toStringAsFixed(2)} KB",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.blue,
                ),
                Text("Drag and drop file here",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
    );
  }

  Widget _cookingDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Cooking Duration (in minutes)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Slider(
          value: double.parse(cookingDuration),
          min: 10,
          max: 60,
          divisions: 10,
          label: '$cookingDuration min',
          activeColor: primaryColor,
          onChanged: (value) {
            setState(() {
              cookingDuration = value.toString();
            });
          },
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('<10',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                cookingDuration == 60
                    ? Text('$cookingDuration min <',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor))
                    : (cookingDuration == 10
                        ? Text('$cookingDuration min> ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor))
                        : Text(
                            '$cookingDuration min',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor),
                          )),
                Text('>60',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        color: primaryColor,
        onPressed: () {
          setState(() {
            currentStep = 1;
          });
        },
        child: Text('Next', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _addIngredientButton() {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: Colors.grey)),
        padding: const EdgeInsets.all(15),
        onPressed: () {
          setState(() {
            ingredientControllers.add(TextEditingController());
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
            ),
            Text('Ingredient', style: TextStyle()),
          ],
        ),
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
  }

  Widget _backNextButtons() {
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, uploadState) {
        return BlocBuilder<UpdateRecipeCubit, UpdateRecipeState>(
          builder: (context, updateState) {
            final isLoading = uploadState is UploadInProgress ||
                updateState is UpdateRecipeLoading;

            return Row(children: [
              Expanded(
                child: MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  padding: const EdgeInsets.all(15),
                  color: Colors.grey[100],
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            currentStep = 0;
                          });
                        },
                  child: Text(
                    'Back',
                    style: TextStyle(
                        color: isLoading ? Colors.grey : Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  padding: const EdgeInsets.all(15),
                  color: primaryColor,
                  onPressed: isLoading ? null : _submitForm,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Finish',
                          style: TextStyle(),
                        ),
                ),
              ),
            ]);
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _submitForm() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        instructionsController.text.isEmpty ||
        ingredientControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    Overlay.of(context).insert(overlayEntry);

    try {
      final ingredients =
          ingredientControllers.map((controller) => controller.text).toList();

      if (isEditing) {
        await context.read<UpdateRecipeCubit>().updateRecipe(
              recipeId: widget.initialData!['_id'],
              title: titleController.text,
              description: descriptionController.text,
              ingredients: ingredients,
              instructions: instructionsController.text,
              category: selectedCategory,
              time: cookingDuration,
              imageFile:
                  selectedImage != null ? File(selectedImage!.path) : null,
            );
      } else {
        if (selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an image")),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) return;

        await context.read<UploadCubit>().uploadRecipe(
              titleController.text,
              descriptionController.text,
              ingredients,
              instructionsController.text,
              selectedCategory,
              cookingDuration,
              File(selectedImage!.path),
              token,
            );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      // Remove loading overlay
      overlayEntry.remove();
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
