import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String defaultActionText;
  final String cancelActionText;
  final Function() onPressedAction;
  final String confirmationText;

  const CustomAlertDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.defaultActionText,
      required this.cancelActionText,
      required this.onPressedAction,
      required this.confirmationText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(content),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(cancelActionText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(defaultActionText),
          onPressed: () {
            onPressedAction();
            final snackback = SnackBar(
              content: Text(confirmationText),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackback);
          },
        ),
      ],
    );
  }
}
