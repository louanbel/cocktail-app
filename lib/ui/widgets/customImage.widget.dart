import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? width;
  final double? height;

  const CustomImage({Key? key, required this.image, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Image.asset('lib/data/assets/landscape-placeholder.png',
          width: width, height: height);
    }

    return image!.startsWith("https")
        ? Image.network(image!, width: width, height: height)
        : Image.memory(Uint8List.fromList(image!.codeUnits),
            width: width, height: height);
  }
}
