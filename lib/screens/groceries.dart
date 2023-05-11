import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/grocery_form.dart';
import 'package:shopping_list_app/widgets/grocery_list_item.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  final List<GroceryItem> _groceryItems = [
    GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!,
    ),
    GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!,
    ),
    GroceryItem(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!,
    ),
  ];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const GroceryFormScreen()),
    );

    if (newItem == null) return;

    setState(() => _groceryItems.add(newItem));
  }

  void _removeItem(GroceryItem item) {
    setState(() => _groceryItems.remove(item));
  }

  void _editItem(GroceryItem item) async {
    final editedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => GroceryFormScreen(groceryItem: item),
      ),
    );

    if (editedItem == null) return;

    setState(
      () => _groceryItems.insert(_groceryItems.indexOf(item), editedItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Slidable(
          key: ValueKey(_groceryItems[index].id),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (ctx) => _editItem(_groceryItems[index]),
                backgroundColor: const Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.edit_note,
                label: 'Edit',
              )
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(
              onDismissed: () => _removeItem(_groceryItems[index]),
            ),
            children: [
              SlidableAction(
                onPressed: (ctx) => _removeItem(_groceryItems[index]),
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          child: GroceryListItem(grocery: _groceryItems[index]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
