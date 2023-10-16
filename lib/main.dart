import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ItemList(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item List App',
      home: ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item List'),
      ),
      body: ItemListWidget(),
      floatingActionButton: AddItemButton(),
    );
  }
}

class ItemListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemList = Provider.of<ItemList>(context);

    return ListView.builder(
      itemCount: itemList.items.length,
      itemBuilder: (context, index) {
        final item = itemList.items[index];

        return ItemTile(item, index);
      },
    );
  }
}

class ItemTile extends StatelessWidget {
  final Item item;
  final int index;

  ItemTile(this.item, this.index);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${index+1}'),
      ),
      title: Text('${item.data}'),
      subtitle: Text('${item.description}'), // Display the description
      onLongPress: () {
        showItemOptions(context, item, index);
      },
    );
  }

  void showItemOptions(BuildContext context, Item item, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Item $index Options'),
          actions: <Widget>[
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                showEditItemBottomSheet(context, item, index);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Provider.of<ItemList>(context, listen: false).deleteItem(index);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showEditItemBottomSheet(BuildContext context, Item item, int index) {
    final itemValueController = TextEditingController(text: item.data.toString());
    final itemDescriptionController = TextEditingController(text: item.description); // Add a controller for the description field

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Edit Item $index'),
              TextField(
                controller: itemValueController,
                decoration: InputDecoration(labelText: 'Add Title'),
              ),
              TextField(
                controller: itemDescriptionController,
                decoration: InputDecoration(labelText: 'Add Description'), // Add a description input field
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate and update the item
                  final newValue = itemValueController.text;
                  final newDescription = itemDescriptionController.text; // Get the description value
                  if (item.updateValue(newValue, newDescription)) {
                    Provider.of<ItemList>(context, listen: false).addItem(item);
                    Provider.of<ItemList>(context, listen: false).deleteItem(index);
                    Navigator.of(context).pop();
                    // Close the bottom sheet
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddItemButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showAddItemDialog(context);
      },
      child: Icon(Icons.add),
    );
  }

  void showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final newItemValueController = TextEditingController();
        final newItemDescriptionController = TextEditingController(); // Add a controller for the description field

        return AlertDialog(
          title: Text('Add a New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensure that the dialog height adjusts to content
            children: [
              TextField(
                controller: newItemValueController,
                decoration: InputDecoration(labelText: 'Add Title'),
              ),
              TextField(
                controller: newItemDescriptionController,
                decoration: InputDecoration(labelText: 'Add Description'), // Add a description input field
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                final newValue = newItemValueController.text;
                final newDescription = newItemDescriptionController.text; // Get the description value
                final item = Item(data: newValue, description: newDescription); // Pass the description to the Item constructor
                Provider.of<ItemList>(context, listen: false).addItem(item);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

class ItemList with ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => _items;

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }

  void deleteItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

class Item {
  dynamic data;
  String description;

  Item({required this.data, this.description = ''});

  bool updateValue(dynamic newValue, String newDescription) {
    if (newValue.runtimeType == data.runtimeType) {
      data = newValue;
      description = newDescription; // Update the description
      return true;
    } else {
      return false;
    }
  }
}
