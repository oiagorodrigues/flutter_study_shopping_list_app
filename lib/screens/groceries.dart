import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/grocery_form.dart';
import 'package:shopping_list_app/widgets/grocery_list_item.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('shopping-list-93ccd-default-rtdb.firebaseio.com',
        'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.body == 'null' || response.body == '') {
        setState(() => _isLoading = false);
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in data.entries) {
        final category = categories.entries.firstWhere(
          (category) => category.value.title == item.value['category'],
        );

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Something went wront! Please try again later.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const GroceryFormScreen()),
    );

    if (newItem == null) return;

    setState(() => _groceryItems.add(newItem));
  }

  void _removeItem(GroceryItem item) async {
    final groceryItemIndex = _groceryItems.indexOf(item);

    setState(() => _groceryItems.remove(item));

    final url = Uri.https('shopping-list-93ccd-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() => _groceryItems.insert(groceryItemIndex, item));

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber, size: 32, color: Colors.red[700]),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'It wasn\'t possible to delete the ${item.name}.\nPlease try again later.',
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _editItem(GroceryItem item) async {
    final editedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => GroceryFormScreen(groceryItem: item),
      ),
    );

    if (editedItem == null) return;

    final groceryItemIndex = _groceryItems.indexOf(item);
    setState(
      () {
        _groceryItems.remove(item);
        _groceryItems.insert(groceryItemIndex, editedItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

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

    if (_error != null) {
      content = Center(child: Text(_error!));
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
