import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../data/models/cocktail.model.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_sms/flutter_sms.dart';

import 'cocktails.state.dart';
import 'cubit.state.dart';

class CocktailListCubit extends Cubit<CocktailListState> {
  final Isar isar;

  CocktailListCubit(this.isar)
      : super(const LoadingState<CocktailListStateData>()) {
    loadCocktails();
  }

  void setIsFavorite(int cocktailId) async {
    try {
      final fetchedCocktails = await isar.cocktails.get(cocktailId);

      if (fetchedCocktails == null) {
        return;
      }

      fetchedCocktails.isFavorite = !fetchedCocktails.isFavorite;

      await isar.writeTxn(() async {
        isar.cocktails.put(fetchedCocktails);
      });

      loadCocktails();
    } catch (e) {
      emit(const FailureState<CocktailListStateData>(
          message: "Error while trying to update favorites"));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void deleteCocktail(int cocktailId) async {
    try {
      await isar.writeTxn(() async {
        isar.cocktails.delete(cocktailId);
      });

      loadCocktails();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void duplicateCocktail(Cocktail cocktail) async {
    try {
      final duplicatedCocktail = Cocktail(
          name: cocktail.name,
          length: cocktail.length,
          description: cocktail.description,
          ingredients: cocktail.ingredients,
          isAlcoholic: cocktail.isAlcoholic,
          image: cocktail.image,
          isFavorite: cocktail.isFavorite);

      await isar.writeTxn(() async {
        isar.cocktails.put(duplicatedCocktail);
      });

      loadCocktails();
    } catch (e) {
      emit(const FailureState<CocktailListStateData>(
          message: "Error while trying to duplicate cocktail"));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String?> sendIngredientList(int cocktailId) async {
    try {
      final fetchedCocktails = await isar.cocktails.get(cocktailId);
      if (fetchedCocktails == null) {
        return null;
      }

      final message =
          "Ingredients of ${fetchedCocktails.name}: \n${fetchedCocktails.ingredients.map((ingredient) => "  - ${ingredient.name} (${ingredient.quantity} ${ingredient.unit})").join("\n")}";

      String result = await sendSMS(message: message, recipients: []);
      if (kDebugMode) {
        print(result);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending SMS");
      }
    }
    return null;
  }

  void initializeDatabase() async {
    final List<Cocktail> cocktails = [
      Cocktail(
        name: "Margarita",
        description:
            "A classic cocktail made with tequila, orange liqueur, and lime juice.",
        ingredients: [
          Ingredient(name: "Tequila", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Triple sec", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 2.5, unit: "cl"),
        ],
        image:
            "https://i.pinimg.com/originals/2d/4e/e6/2d4ee618e05cc6bff524bae855be9555.jpg",
        length: 10,
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Mojito",
        description:
            "A refreshing Cuban cocktail made with rum, mint leaves, sugar, and lime.",
        ingredients: [
          Ingredient(name: "White rum", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Fresh mint leaves", quantity: 6, unit: "u"),
          Ingredient(name: "Sugar", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 2.5, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Piña Colada",
        description:
            "A tropical cocktail made with rum, pineapple, and coconut milk.",
        ingredients: [
          Ingredient(name: "White rum", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Pineapple juice", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Coconut milk", quantity: 3.0, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/upgsue1668419912.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Daiquiri",
        description: "A cocktail made with rum, lime juice, and sugar.",
        ingredients: [
          Ingredient(name: "White rum", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 2.5, unit: "cl"),
          Ingredient(name: "Sugar", quantity: 2.0, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/mrz9091589574515.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Cosmopolitan",
        description:
            "A refreshing cocktail made with vodka, triple sec, cranberry juice, and lime.",
        ingredients: [
          Ingredient(name: "Vodka", quantity: 4.0, unit: "cl"),
          Ingredient(name: "Triple sec", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Cranberry juice", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 0.5, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/kpsajh1504368362.jpg",
        isAlcoholic: true,
      ),
    ];

    final List<Cocktail> mocktails = [
      Cocktail(
        name: "Virgin Mojito",
        description:
            "A non-alcoholic version of the famous Mojito, with mint, sugar, and lime.",
        ingredients: [
          Ingredient(name: "Fresh mint leaves", quantity: 6, unit: "u"),
          Ingredient(name: "Sugar", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 2.5, unit: "cl"),
        ],
        length: 15,
        image:
            "https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg",
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Virgin Piña Colada",
        description:
            "A non-alcoholic version of Piña Colada, with pineapple and coconut milk.",
        ingredients: [
          Ingredient(name: "Pineapple juice", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Coconut milk", quantity: 3.0, unit: "cl"),
        ],
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Virgin Mary",
        description:
            "A non-alcoholic version of Bloody Mary, with tomato juice, lemon, Worcestershire sauce, and spices.",
        ingredients: [
          Ingredient(name: "Tomato juice", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Lemon juice", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Worcestershire sauce", quantity: 1.0, unit: "cl"),
        ],
        image:
            "https://www.thecocktaildb.com/images/media/drink/upgsue1668419912.jpg",
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Nojito",
        description:
            "A non-alcoholic version of Mojito, with mint, sugar, and lime.",
        ingredients: [
          Ingredient(name: "Fresh mint leaves", quantity: 6, unit: "u"),
          Ingredient(name: "Sugar", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Lime juice", quantity: 2.5, unit: "cl"),
        ],
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Fruit Punch",
        description: "A refreshing blend of tropical fruit juices.",
        ingredients: [
          Ingredient(name: "Pineapple juice", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Orange juice", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Mango juice", quantity: 5.0, unit: "cl"),
        ],
        image:
            "https://www.thecocktaildb.com/images/media/drink/wyrsxu1441554538.jpg",
        isAlcoholic: false,
      ),
    ];

    await isar.writeTxn(() async {
      isar.cocktails.putAll([...mocktails, ...cocktails]);
    });

    loadCocktails();
  }

  void loadCocktails() async {
    final fetchedCocktails = await isar.cocktails.where().findAll();
    emit(SuccessState<CocktailListStateData>(
        data: CocktailListStateData(cocktails: fetchedCocktails)));
  }

  void updateCocktail(Id id, String name, int? length, String description,
      List<Ingredient> ingredients, bool isAlcoholic, File? imageFile) async {
    Cocktail? existingCocktail = await isar.cocktails.get(id);
    try {
      if (existingCocktail == null) {
        return;
      }

      existingCocktail.name = name;
      existingCocktail.length = length ?? -1;
      existingCocktail.description = description;
      existingCocktail.ingredients = ingredients;
      existingCocktail.isAlcoholic = isAlcoholic;
      existingCocktail.image = imageFile != null
          ? String.fromCharCodes(imageFile.readAsBytesSync())
          : null;

      await isar.writeTxn(() async {
        isar.cocktails.put(existingCocktail);
      });
      loadCocktails();
    } catch (e) {
      emit(const FailureState<CocktailListStateData>(
          message: "Error while trying to update cocktail"));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void addCocktail(String name, int? length, String? description,
      List<Ingredient> ingredients, bool isAlcoholic, File? imageFile) async {
    try {
      Uint8List? imageBytes;
      if (imageFile != null) {
        imageBytes = imageFile.readAsBytesSync();
      }

      final cocktail = Cocktail(
          name: name,
          length: length ?? -1,
          description: description,
          ingredients: ingredients,
          isAlcoholic: isAlcoholic,
          image: imageBytes != null ? String.fromCharCodes(imageBytes) : null);
      await isar.writeTxn(() async {
        isar.cocktails.put(cocktail);
      });

      loadCocktails();
    } catch (e) {
      emit(const FailureState<CocktailListStateData>(
          message: "Error while trying to add cocktail"));
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
