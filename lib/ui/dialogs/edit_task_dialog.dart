import 'package:flutter/material.dart';
import 'package:todo/models/item.model.dart';

class EditTaskDialog extends StatelessWidget {
  const EditTaskDialog({
    Key key,
    @required TextEditingController itemTitleController,
    this.item,
    this.title = "Edit",
  })  : _itemTitleController = itemTitleController,
        super(key: key);

  final TextEditingController _itemTitleController;
  final Item item;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _itemTitleController,
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Save'),
          onPressed: () {
            if (_itemTitleController.text == "" ||
                _itemTitleController.text == item.title) {
              Navigator.pop(context, false);
            } else {
              item.title = _itemTitleController.text;

              Navigator.pop(context, true);
            }
          },
        ),
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
  }
}
