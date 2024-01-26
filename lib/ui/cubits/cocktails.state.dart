import 'package:tp_cocktail/data/models/cocktail.model.dart';

import 'cubit.state.dart';

typedef CocktailListState = CubitState<CocktailListStateData>;

class CocktailListStateData {
  const CocktailListStateData({
    required this.cocktails,
  });

  final List<Cocktail> cocktails;
}
