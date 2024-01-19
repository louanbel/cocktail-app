import 'package:isar/isar.dart';

part 'cocktail.model.g.dart';


@collection
@Name('Cocktails')
class Cocktail {
  Cocktail({required this.name, this.length, this.description, required this.ingredients, this.image, this.isAlcoholic = false, this.isFavorite = false});

  Id id = Isar.autoIncrement;
  late String? image;
  late String name;
  late int? length;
  late String? description;
  late List<Ingredient> ingredients;
  late bool isAlcoholic;
  late bool isFavorite;
}

@embedded
class Ingredient {
  Ingredient({this.name, this.quantity = 1, this.unit = "u"});
  String? name;
  double? quantity;
  String? unit;
}
