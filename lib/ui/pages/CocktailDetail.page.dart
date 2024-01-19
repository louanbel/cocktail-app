import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tp_cocktail/data/models/cocktail.model.dart';
import 'package:tp_cocktail/ui/widgets/customAlertDialog.widget.dart';

import '../cubits/cocktails.cubit.dart';
import 'CocktailForm.page.dart';

class CocktailDetail extends StatefulWidget {
  final Cocktail cocktail;

  const CocktailDetail({Key? key, required this.cocktail}) : super(key: key);

  @override
  _CocktailDetailState createState() => _CocktailDetailState();
}

class _CocktailDetailState extends State<CocktailDetail> {
  Cocktail cocktail = Cocktail(name: "N/A", ingredients: []);

  Future<void> _showDeleteConfirmationDialog(cubit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
            title: "Delete confirmation",
            content: "Are you sure you want to delete this cocktail?",
            defaultActionText: "Delete",
            cancelActionText: "Cancel",
            confirmationText: "Successfully deleted cocktail",
            onPressedAction: () {
              cubit.deleteCocktail(cocktail.id);
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pop(); // To also close the Cocktail detail page
            });
      },
    );
  }

  Future<void> _showDuplicateConfirmationDialog(cubit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
            title: "Duplicate confirmation",
            content: "Are you sure you want to duplicate this cocktail?",
            defaultActionText: "Duplicate",
            cancelActionText: "Cancel",
            confirmationText: "Successfully duplicated cocktail",
            onPressedAction: () {
              cubit.duplicateCocktail(cocktail);
              Navigator.of(context).pop();
            });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    cocktail = widget.cocktail;
  }

  @override
  Widget build(BuildContext context) {
    final cocktailListCubit = BlocProvider.of<CocktailListCubit>(context);

    return BlocListener<CocktailListCubit, List<Cocktail>>(
        listener: (BuildContext context, List<Cocktail> state) {
          setState(() {
            cocktail = state.firstWhere((c) => c.id == widget.cocktail.id);
          });
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(cocktail.name),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      cocktail.isFavorite = !cocktail.isFavorite;
                    });
                    cocktailListCubit.setIsFavorite(widget.cocktail.id);
                  },
                  icon: Icon(cocktail.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(children: [
                      if (cocktail.image != null)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: cocktail.image != null
                                ? cocktail.image!.startsWith("https") ? Image.network(cocktail.image!, width: 200, height: 200) : Image.memory(Uint8List.fromList(cocktail.image!.codeUnits), height: 200, width: 200)
                                : Image.asset(
                                    'lib/data/assets/landscape-placeholder.png')),
                      if (cocktail.length != null && cocktail.length! >= -1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8EAFF),
                            border: Border.all(
                              color: const Color(0xFFD8EAFF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${cocktail.length} min",
                            style: const TextStyle(
                                fontSize: 20, color: Color(0xFF3790FD)),
                          ),
                        )
                    ]),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text("Ingredients",
                            style: TextStyle(fontSize: 20)),
                        IconButton(
                            onPressed: () {
                              cocktailListCubit.sendIngredientList(cocktail.id);
                            },
                            icon: const Icon(Icons.share))
                      ]),
                      for (var ingredient in cocktail.ingredients)
                        Text(
                            ' - ${ingredient.name} (${ingredient.quantity} ${ingredient.unit})'),
                    ],
                  ),
                  if (cocktail.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Description",
                              style: TextStyle(fontSize: 20)),
                          Text(cocktail.description!),
                        ],
                      ),
                    )
                ],
              ),
            ),
            floatingActionButton: SpeedDial(icon: Icons.menu, children: [
              SpeedDialChild(
                label: "Edit",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CocktailForm(
                        existingCocktail: cocktail,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.edit),
              ),
              SpeedDialChild(
                label: "Duplicate",
                onTap: () {
                  _showDuplicateConfirmationDialog(cocktailListCubit);
                },
                child: const Icon(Icons.copy),
              ),
              SpeedDialChild(
                label: "Delete",
                onTap: () {
                  _showDeleteConfirmationDialog(cocktailListCubit);
                },
                child: const Icon(Icons.delete),
              ),
            ])));
  }
}
