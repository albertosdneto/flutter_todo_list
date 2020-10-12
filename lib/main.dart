import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models/item.model.dart';
import 'ui/dialogs/confirmation_dialog.dart';
import 'ui/dialogs/edit_task_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var uuid = Uuid();

  var itemList = List<Item>();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO List"),
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children: List.generate(itemList.length, (index) {
          return Card(
            key: ValueKey(itemList[index].id),
            child: Dismissible(
              key: Key(itemList[index].id),
              child: CheckboxListTile(
                title: Text(
                  itemList[index].title,
                  style: TextStyle(
                    decoration: itemList[index].done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(itemList[index].id),
                value: itemList[index].done,
                onChanged: (bool value) {
                  setState(() {
                    itemList[index].done = !itemList[index].done;
                  });
                  save();
                },
              ),
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                alignment: Alignment.centerLeft,
                color: Colors.blueAccent,
                child: Icon(Icons.edit),
              ),
              secondaryBackground: Container(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                alignment: Alignment.centerRight,
                color: Colors.redAccent,
                child: Icon(Icons.delete),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  var result = await _showConfirmationDialog(
                    context,
                    'delete',
                  );
                  if (result) {
                    remove(index);
                  }
                } else {
                  var result = await _showEditDialog(
                    context,
                    itemList[index],
                    "Edit",
                  );
                  if (result) {
                    update(index, itemList[index]);
                  }
                }
                return false;
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Item newItem = Item();
          var result = await _showEditDialog(
            context,
            newItem,
            "Save",
          );
          if (result) {
            add(newItem);
          }
        },
        tooltip: 'Add New Task',
        child: Icon(Icons.add),
      ),
    );
  }

  void add(Item item) {
    item.id = uuid.v4();
    item.done = false;

    setState(() {
      itemList.add(item);
    });

    save();
  }

  void remove(int index) {
    setState(() {
      itemList.removeAt(index);
    });
    save();
  }

  void update(int index, Item item) {
    setState(() {
      itemList[index] = item;
    });
    save();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((item) => Item.fromJson(item)).toList();
      setState(() {
        itemList = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(itemList));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Item item = itemList.removeAt(oldIndex);
      itemList.insert(newIndex, item);
    });
    save();
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationAlertDialog(
          action: 'delete',
        );
      },
    );
  }

  Future<bool> _showEditDialog(BuildContext context, Item item, String title) {
    TextEditingController _itemTitleController = TextEditingController();
    _itemTitleController.text = item.title;
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EditTaskDialog(
          itemTitleController: _itemTitleController,
          item: item,
          title: title,
        );
      },
    );
  }
}
