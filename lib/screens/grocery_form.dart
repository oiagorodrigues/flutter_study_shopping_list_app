import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryFormScreen extends StatefulWidget {
  const GroceryFormScreen({super.key, this.groceryItem});

  final GroceryItem? groceryItem;

  @override
  State<GroceryFormScreen> createState() => _GroceryFormScreenState();
}

class _GroceryFormScreenState extends State<GroceryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isSubmiting = false;
  String? _enteredName;
  int? _enteredQuantity;
  Category? _selectedCategory;

  bool get _isEdit {
    return widget.groceryItem != null;
  }

  @override
  void initState() {
    super.initState();
    _enteredName = _isEdit ? widget.groceryItem!.name : '';
    _enteredQuantity = _isEdit ? widget.groceryItem!.quantity : 1;
    _selectedCategory = _isEdit
        ? widget.groceryItem!.category
        : categories[Categories.vegetables]!;
  }

  Future<http.Response> _updateItem() async {
    final payload = {
      'id': widget.groceryItem!.id,
      'name': _enteredName!,
      'quantity': _enteredQuantity!,
      'category': _selectedCategory!.title,
    };

    final url = Uri.https('shopping-list-93ccd-default-rtdb.firebaseio.com',
        'shopping-list/${widget.groceryItem!.id}.json');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    return response;
  }

  Future<http.Response> _saveItem() async {
    final payload = {
      'name': _enteredName!,
      'quantity': _enteredQuantity!,
      'category': _selectedCategory!.title,
    };

    final url = Uri.https('shopping-list-93ccd-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    return response;
  }

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isSubmiting = true);

      try {
        final response = _isEdit ? await _updateItem() : await _saveItem();
        final Map<String, dynamic> data = json.decode(response.body);

        if (context.mounted) {
          Navigator.of(context).pop(
            GroceryItem(
              id: data['name'],
              name: _enteredName!,
              quantity: _enteredQuantity!,
              category: _selectedCategory!,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _isEdit
                        ? 'It wasn\'t possible to update this item.'
                        : 'It wasn\'t possible to add this item.',
                  ),
                ),
                const Expanded(
                  child: Text('Please, try again later!'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add a new item')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  initialValue: _enteredName,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }

                    return null;
                  },
                  onSaved: (value) => (_enteredName = value!),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredQuantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid positive number.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) => setState(
                          () => (_selectedCategory = value!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: !_isSubmiting
                          ? () => _formKey.currentState!.reset()
                          : null,
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: !_isSubmiting ? _submitItem : null,
                      child: Row(
                        children: [
                          if (_isSubmiting)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          _isEdit
                              ? const Text('Save item')
                              : const Text('Add item'),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
