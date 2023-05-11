import 'package:flutter/material.dart';
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
  String? _enteredName;
  String? _enteredQuantity;
  Category? _selectedCategory;

  bool get _isEdit {
    return widget.groceryItem != null;
  }

  @override
  void initState() {
    super.initState();
    _enteredName = _isEdit ? widget.groceryItem!.name : '';
    _enteredQuantity = _isEdit ? widget.groceryItem!.quantity.toString() : '1';
    _selectedCategory = _isEdit
        ? widget.groceryItem!.category
        : categories[Categories.vegetables]!;
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName!,
          quantity: int.parse(_enteredQuantity!),
          category: _selectedCategory!,
        ),
      );
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
                        initialValue: _enteredQuantity,
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
                        onSaved: (value) => (_enteredQuantity = value!),
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
                      onPressed: () => _formKey.currentState!.reset(),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _saveItem,
                      child: const Text('Add item'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
