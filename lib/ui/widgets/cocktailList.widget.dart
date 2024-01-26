import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tp_cocktail/ui/widgets/customImage.widget.dart';

import '../../data/models/cocktail.model.dart';
import '../pages/CocktailDetail.page.dart';
import '../utils/string_formatter.dart';

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
              leading: CustomImage(image: cocktail.image),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(StringFormatter.format(cocktail.name, 15)),
                  if (cocktail.length != null && cocktail.length! > -1)
                    Text(
                      '${cocktail.length} min',
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              subtitle: Text(StringFormatter.format(cocktail.description, 50)),
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
