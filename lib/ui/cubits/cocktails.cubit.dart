import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../data/models/cocktail.model.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_sms/flutter_sms.dart';

class CocktailListCubit extends Cubit<List<Cocktail>> {
  final Isar isar;

  CocktailListCubit(this.isar) : super([]);

  void setIsFavorite(int cocktailId) async {
    final fetchedCocktails = await isar.cocktails.get(cocktailId);
    if (fetchedCocktails == null) {
      return;
    }

    fetchedCocktails.isFavorite = !fetchedCocktails.isFavorite;

    await isar.writeTxn(() async {
      isar.cocktails.put(fetchedCocktails);
    });

    loadCocktails();
  }

  void deleteCocktail(int cocktailId) async {
    await isar.writeTxn(() async {
      isar.cocktails.delete(cocktailId);
    });

    loadCocktails();
  }

  void duplicateCocktail(Cocktail cocktail) async {
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
  }

  void sendIngredientList(int cocktailId) async {
    final fetchedCocktails = await isar.cocktails.get(cocktailId);
    if (fetchedCocktails == null) {
      return;
    }

    final message =
        "Ingredients of ${fetchedCocktails.name}: \n${fetchedCocktails.ingredients.map((ingredient) => "  - ${ingredient.name} (${ingredient.quantity} ${ingredient.unit})").join("\n")}";

    String result = await sendSMS(message: message, recipients: []);

    if (kDebugMode) {
      print(result);
    }
  }

  void initializeDatabase() async {
    final List<Cocktail> cocktails = [
      Cocktail(
        name: "Margarita",
        description:
            "Un cocktail classique à base de tequila, de liqueur d'orange et de jus de citron vert.",
        ingredients: [
          Ingredient(name: "Tequila", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Triple sec", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 2.5, unit: "cl"),
        ],
        image:
            "https://i.pinimg.com/originals/2d/4e/e6/2d4ee618e05cc6bff524bae855be9555.jpg",
        length: 10,
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Mojito",
        description:
            "Un rafraîchissant cocktail cubain à base de rhum, de menthe, de sucre et de citron vert.",
        ingredients: [
          Ingredient(name: "Rhum blanc", quantity: 5.0, unit: "cl"),
          Ingredient(
              name: "Feuilles de menthe fraîche", quantity: 6, unit: "u"),
          Ingredient(name: "Sucre", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 2.5, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Piña Colada",
        description:
            "Un cocktail tropical à base de rhum, d'ananas et de lait de coco.",
        ingredients: [
          Ingredient(name: "Rhum blanc", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Jus d'ananas", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Lait de coco", quantity: 3.0, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/upgsue1668419912.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Daiquiri",
        description:
            "Un cocktail à base de rhum, de jus de citron vert et de sucre.",
        ingredients: [
          Ingredient(name: "Rhum blanc", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 2.5, unit: "cl"),
          Ingredient(name: "Sucre", quantity: 2.0, unit: "cl"),
        ],
        length: 10,
        image:
            "https://www.thecocktaildb.com/images/media/drink/mrz9091589574515.jpg",
        isAlcoholic: true,
      ),
      Cocktail(
        name: "Cosmopolitan",
        description:
            "Un cocktail rafraîchissant à base de vodka, de triple sec, de jus de canneberge et de citron vert.",
        ingredients: [
          Ingredient(name: "Vodka", quantity: 4.0, unit: "cl"),
          Ingredient(name: "Triple sec", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Jus de canneberge", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 0.5, unit: "cl"),
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
            "Une version sans alcool du célèbre Mojito, avec de la menthe, du sucre et du citron vert.",
        ingredients: [
          Ingredient(
              name: "Feuilles de menthe fraîche", quantity: 6, unit: "u"),
          Ingredient(name: "Sucre", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 2.5, unit: "cl"),
        ],
        length: 15,
        image:
            "https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg",
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Virgin Piña Colada",
        description:
            "Une version sans alcool de la Piña Colada, avec de l'ananas et du lait de coco.",
        ingredients: [
          Ingredient(name: "Jus d'ananas", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Lait de coco", quantity: 3.0, unit: "cl"),
        ],
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Virgin Mary",
        description:
            "Une version sans alcool du Bloody Mary, avec du jus de tomate, du citron, de la sauce Worcestershire et des épices.",
        ingredients: [
          Ingredient(name: "Jus de tomate", quantity: 9.0, unit: "cl"),
          Ingredient(name: "Jus de citron", quantity: 1.5, unit: "cl"),
          Ingredient(name: "Sauce Worcestershire", quantity: 1.0, unit: "cl"),
        ],
        image:
            "https://www.thecocktaildb.com/images/media/drink/upgsue1668419912.jpg",
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Nojito",
        description:
            "Une version sans alcool du Mojito, avec de la menthe, du sucre et du citron vert.",
        ingredients: [
          Ingredient(
              name: "Feuilles de menthe fraîche", quantity: 6, unit: "u"),
          Ingredient(name: "Sucre", quantity: 2.0, unit: "cl"),
          Ingredient(name: "Jus de citron vert", quantity: 2.5, unit: "cl"),
        ],
        isAlcoholic: false,
      ),
      Cocktail(
        name: "Fruit Punch",
        description: "Un mélange rafraîchissant de jus de fruits tropicaux.",
        ingredients: [
          Ingredient(name: "Jus d'ananas", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Jus d'orange", quantity: 5.0, unit: "cl"),
          Ingredient(name: "Jus de mangue", quantity: 5.0, unit: "cl"),
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
    emit(fetchedCocktails);
  }

  void updateCocktail(Id id, String name, int? length, String description,
      List<Ingredient> ingredients, bool isAlcoholic, File? imageFile) async {
    Cocktail? existingCocktail = await isar.cocktails.get(id);

    if (existingCocktail == null) {
      return;
    }
    existingCocktail.name = name;
    existingCocktail.length = length ?? -1;
    existingCocktail.description = description;
    existingCocktail.ingredients = ingredients;
    existingCocktail.isAlcoholic = isAlcoholic;
    if (imageFile != null) {
      existingCocktail.image =
          String.fromCharCodes(imageFile.readAsBytesSync());
    }

    await isar.writeTxn(() async {
      isar.cocktails.put(existingCocktail);
    });
    loadCocktails();
  }

  void addCocktail(String name, int? length, String? description,
      List<Ingredient> ingredients, bool isAlcoholic, File? imageFile) async {
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
  }
}
