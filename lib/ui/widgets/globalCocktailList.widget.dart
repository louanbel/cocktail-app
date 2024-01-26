import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_cocktail/ui/pages/CocktailForm.page.dart';
import 'package:tp_cocktail/ui/utils/string_formatter.dart';
import '../cubits/cocktails.cubit.dart';
import '../cubits/cocktails.state.dart';
import '../cubits/cubit.state.dart';
import '../pages/CocktailDetail.page.dart';
import 'cocktailList.widget.dart';
import 'customImage.widget.dart';

class GlobalCocktailList extends StatelessWidget {
  const GlobalCocktailList({Key? key});

  @override
  Widget build(BuildContext context) {
    final cocktailListCubit = context.read<CocktailListCubit>();

    return BlocBuilder<CocktailListCubit, CubitState<CocktailListStateData>>(
      builder: (context, state) {
        if (state is LoadingState<CocktailListStateData>) {
          return const CircularProgressIndicator();
        } else if (state is SuccessState<CocktailListStateData>) {
          final cocktails = state.data.cocktails;
          final alcoholicCocktails = cocktails
              .where((cocktail) => cocktail.isAlcoholic == true)
              .toList();
          final nonAlcoholicCocktails = cocktails
              .where((cocktail) => cocktail.isAlcoholic == false)
              .toList();
          final favoriteCocktails =
          cocktails.where((cocktail) => cocktail.isFavorite == true).toList();

          if (cocktails.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text("Cocktail recipes"),
              ),
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You don't have any cocktail yet!"),
                    const Text(
                      "You can create one or click on the button below to generate some cocktails.",
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        cocktailListCubit.initializeDatabase();
                      },
                      child: const Text("Generate"),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CocktailForm(),
                    ),
                  );
                },
                tooltip: 'Add',
                child: const Icon(Icons.add),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text("Cocktail recipes"),
            ),
            body: CustomScrollView(
              slivers: [
                if (favoriteCocktails.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                            padding:
                            EdgeInsets.only(left: 10, top: 12, bottom: 0),
                            child: Text(
                              "My favorites",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 100,
                          child: CocktailList(cocktails: favoriteCocktails),
                        ),
                      ],
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, top: 12, bottom: 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My favorites",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("You don't have any favorite yet! Add one!"),
                          ]),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(left: 10, top: 12, bottom: 0),
                          child: Text(
                            "Cocktails",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        height: 100,
                        child: CocktailList(cocktails: alcoholicCocktails),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 0),
                          child: Text(
                            "Mocktails",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        height: 100,
                        child: CocktailList(cocktails: nonAlcoholicCocktails),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 8),
                    child: Text(
                      'All cocktails',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final cocktail = cocktails[index];
                    return ListTile(
                      leading: CustomImage(image: cocktail.image),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(StringFormatter.format(cocktail.name, 20)),
                          if (cocktail.length != null && cocktail.length! >= -1)
                            Text(
                              '${cocktail.length} min',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                      subtitle: Text(StringFormatter.format(cocktail.description, 100)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CocktailDetail(cocktail: cocktails[index]),
                          ),
                        );
                      },
                    );
                  }, childCount: cocktails.length),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CocktailForm(),
                  ),
                );
              },
              tooltip: 'Add',
              child: const Icon(Icons.add),
            ),
          );
        } else if (state is FailureState<CocktailListStateData>) {
          return Center(
            child: Text("Failed to load cocktails: ${state.message}"),
          );
        } else {
          return const Center(
            child: Text("Unknown state"),
          );
        }
      },
    );
  }
}
