import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tp_cocktail/ui/widgets/customAlertDialog.widget.dart';
import 'package:tp_cocktail/ui/widgets/globalCocktailList.widget.dart';
import 'data/models/cocktail.model.dart';
import 'ui/cubits/cocktails.cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([CocktailSchema], directory: directory.path);
  final cocktailListCubit = CocktailListCubit(isar);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CocktailListCubit>(
          create: (context) => cocktailListCubit,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  void showErrorDialog(
      BuildContext context,
      String title,
      String content,
      String defaultActionText,
      String cancelActionText,
      String confirmationText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: title,
          content: content,
          defaultActionText: defaultActionText,
          cancelActionText: cancelActionText,
          onPressedAction: () {
            Navigator.of(context).pop();
          },
          confirmationText: confirmationText,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cocktail recipes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFCFF),
      ),
      home: const GlobalCocktailList(),
    );
  }
}
