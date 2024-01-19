import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/cocktail.model.dart';
import '../pages/CocktailDetail.page.dart';

class CocktailList extends StatelessWidget {
  final List<Cocktail> cocktails;

  const CocktailList({Key? key, required this.cocktails});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: cocktails.length,
      itemBuilder: (context, index) {
        final cocktail = cocktails[index];
        return SizedBox(
          width: 320,
          child: Center(
            child: ListTile(
              leading: cocktail.image != null
                  ? cocktail.image!.startsWith("https")
                      ? Image.network(cocktail.image!)
                      : Image.memory(
                          Uint8List.fromList(cocktail.image!.codeUnits))
                  : Image.asset('lib/data/assets/landscape-placeholder.png'),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cocktail.name.length > 15
                      ? "${cocktail.name.substring(0, 15)}..."
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
                  ? "${cocktail.description!.substring(0, 50)}..."
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
            ),
          ),
        );
      },
    );
  }
}
