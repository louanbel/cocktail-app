import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tp_cocktail/data/models/cocktail.model.dart';
import 'package:tp_cocktail/ui/utils/string_formatter.dart';
import 'dart:io';

import '../cubits/cocktails.cubit.dart';
import '../widgets/customImage.widget.dart';

class CocktailForm extends StatefulWidget {
  final Cocktail? existingCocktail;

  const CocktailForm({super.key, this.existingCocktail});

  @override
  CocktailFormState createState() => CocktailFormState();
}

class CocktailFormState extends State<CocktailForm> {
  // Controller variables
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientNameController =
      TextEditingController();
  final TextEditingController ingredientQuantityController =
      TextEditingController();
  final ImagePicker picker = ImagePicker();

  // Ingredient variables
  Ingredient ingredientItem = Ingredient();
  bool isAlcoholic = false;
  String selectedUnit = 'u';
  bool editMode = false;
  File? imageFile;
  String? imageBytes;
  List<Ingredient> ingredientsList = [];

  // Error boolean variables
  bool nameError = false;
  bool descriptionError = false;
  bool lengthError = false;
  bool ingredientQuantityError = false;
  bool ingredientNameError = false;
  bool ingredientError = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingCocktail != null) {
      var existingCocktail = widget.existingCocktail!;
      nameController.text = existingCocktail.name;
      lengthController.text =
          existingCocktail.length != null && existingCocktail.length! > 0
              ? existingCocktail.length.toString()
              : '';
      descriptionController.text = existingCocktail.description ?? '';
      ingredientsList = List<Ingredient>.from(existingCocktail.ingredients);
      isAlcoholic = existingCocktail.isAlcoholic;
      editMode = true;
      imageBytes = existingCocktail.image;
    }
  }

  void validateForm() {
    final name = nameController.text;
    final length = lengthController.text.isNotEmpty
        ? int.tryParse(lengthController.text)
        : null;
    final description = descriptionController.text;
    final ingredients = ingredientsList;
    setState(() {
      lengthError = lengthController.text.isNotEmpty && length == null;
      nameError = name.isEmpty;
      ingredientError = ingredients.isEmpty;
    });
    if (!nameError && !lengthError && !ingredientError) {
      if (editMode) {
        context.read<CocktailListCubit>().updateCocktail(
            widget.existingCocktail!.id,
            name,
            length,
            description,
            ingredients,
            isAlcoholic,
            imageFile);
        final editedCocktail = Cocktail(
          name: name,
          length: length,
          description: description,
          ingredients: ingredients,
          isAlcoholic: isAlcoholic,
          image: imageBytes,
        );
        Navigator.of(context).pop(editedCocktail);
        return;
      } else {
        context.read<CocktailListCubit>().addCocktail(
            name, length, description, ingredients, isAlcoholic, imageFile);
        Navigator.of(context).pop();
      }
    }
  }

  void addIngredient() {
    setState(() {
      ingredientQuantityError =
          double.tryParse(ingredientQuantityController.text) == null ||
              ingredientItem.quantity! < 0;
      ingredientNameError = ingredientNameController.text.isEmpty;
    });
    if (!ingredientQuantityError && !ingredientNameError) {
      setState(() {
        ingredientsList.add(ingredientItem);
        ingredientError = ingredientsList.isEmpty;
        ingredientItem = Ingredient();
        ingredientNameController.clear();
        ingredientQuantityController.clear();
        selectedUnit = 'u';
      });
    }
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < ingredientsList.length) {
      setState(() {
        ingredientsList.removeAt(index);
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        imageBytes = String.fromCharCodes(imageFile!.readAsBytesSync());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? "Edit cocktail" : 'Add cocktail'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child:
                                Text('Name*', style: TextStyle(fontSize: 18))),
                        TextField(
                            controller: nameController,
                            onChanged: (e) => setState(() {
                                  nameError = nameController.text.isEmpty;
                                }),
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Cocktail name',
                                errorText:
                                    nameError ? "Name is required" : null)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isAlcoholic = !isAlcoholic;
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isAlcoholic,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      isAlcoholic = newValue ?? false;
                                    });
                                  },
                                ),
                                const Text('Is alcoholic',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Description',
                                    style: TextStyle(fontSize: 18))),
                            TextField(
                                controller: descriptionController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: 'Description',
                                    errorText: descriptionError
                                        ? "Description is required"
                                        : null)),
                          ])),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Length', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 170,
                          child: TextField(
                              controller: lengthController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Length',
                                suffixText: 'min',
                                errorText:
                                    lengthError ? "Invalid length" : null,
                              )),
                        ),
                      ]),
                  const SizedBox(height: 16),
                  const Text('Ingredients*', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Column(
                    children:
                        ingredientsList.asMap().entries.map((ingredientEntry) {
                      final ingredient = ingredientEntry.value;
                      return Row(
                        children: [
                          Expanded(
                              child: Text(ingredient.name != null
                                  ? StringFormatter.format(ingredient.name, 15)
                                  : '-')),
                          SizedBox(
                            width: 60,
                            child: Text(ingredient.quantity != null
                                ? ingredient.quantity.toString()
                                : '-'),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(ingredient.unit != null
                                ? ingredient.unit!
                                : 'N/A'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                removeIngredient(ingredientEntry.key),
                            child:
                                const Text('-', style: TextStyle(fontSize: 24)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: (e) => ingredientItem.name = e,
                              controller: ingredientNameController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Name',
                                errorText: ingredientNameError
                                    ? "Name is required"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: (e) {
                                setState(() {
                                  final parsedValue = double.tryParse(e);
                                  ingredientItem.quantity = parsedValue ?? 0;
                                  ingredientQuantityError =
                                      parsedValue == null || parsedValue < 0;
                                });
                              },
                              controller: ingredientQuantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Quantity',
                                errorText: ingredientQuantityError
                                    ? "Invalid quantity"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownMenu<String>(
                                width: 80,
                                initialSelection: selectedUnit,
                                onSelected: (String? value) {
                                  setState(() {
                                    ingredientItem.unit = value!;
                                    selectedUnit = value;
                                  });
                                },
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry<String>(
                                    value: "u",
                                    label: "u",
                                  ),
                                  DropdownMenuEntry<String>(
                                    value: "cl",
                                    label: "cl",
                                  ),
                                  DropdownMenuEntry<String>(
                                    value: "gram",
                                    label: "gram",
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: addIngredient,
                        child: const Text('+', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (ingredientError)
                    const Text(
                      'At least one ingredient is required',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Image', style: TextStyle(fontSize: 18))),
                  if (imageBytes != null)
                    Row(children: [
                      CustomImage(image: imageBytes, width: 200, height: 200),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              imageFile = null;
                              imageBytes = null;
                            });
                          },
                          icon: const Icon(Icons.close)),
                    ])
                  else
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Pick an Image'),
                    ),
                  const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: Text("* required fields")),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          validateForm();
                        },
                        child: Text(editMode ? "Update" : 'Add',
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
