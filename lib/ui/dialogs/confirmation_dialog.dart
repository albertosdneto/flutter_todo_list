import 'package:flutter/material.dart';

class ConfirmationAlertDialog extends StatelessWidget {
  final String action;
  const ConfirmationAlertDialog({
    Key key,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Do you want to $action this item?'),
      actions: <Widget>[
        FlatButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
  }
}
