import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_cocktail/ui/pages/CocktailForm.page.dart';
import '../../data/models/cocktail.model.dart';
import '../cubits/cocktails.cubit.dart';
import '../pages/CocktailDetail.page.dart';
import 'cocktailList.widget.dart';

class GlobalCocktailList extends StatefulWidget {
  const GlobalCocktailList({Key? key});

  @override
  _GlobalCocktailListState createState() => _GlobalCocktailListState();
}

class _GlobalCocktailListState extends State<GlobalCocktailList> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CocktailListCubit>(context).loadCocktails();
  }

  @override
  Widget build(BuildContext context) {
    final cocktailListCubit = BlocProvider.of<CocktailListCubit>(context);

    return BlocBuilder<CocktailListCubit, List<Cocktail>>(
      builder: (context, cocktails) {
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
                    leading: cocktail.image != null
                        ? cocktail.image!.startsWith("https")
                            ? Image.network(cocktail.image!)
                            : Image.memory(
                                Uint8List.fromList(cocktail.image!.codeUnits))
                        : Image.asset(
                            'lib/data/assets/landscape-placeholder.png'),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cocktail.name.length > 20
                            ? "${cocktail.name.substring(0, 20)}..."
                            : cocktail.name),
                        if (cocktail.length != null && cocktail.length! >= -1)
                          Text(
                            '${cocktail.length} min',
                            style:
                                const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    subtitle: Text(cocktail.description != null
                        ? cocktail.description!.length > 100
                            ? "${cocktail.description!.substring(0, 100)}..."
                            : cocktail.description!
                        : ""),
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
      },
    );
  }
}
