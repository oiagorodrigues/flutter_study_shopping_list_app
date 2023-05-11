import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  const GroceryListItem({
    super.key,
    required this.grocery,
  });

  final GroceryItem grocery;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        color: grocery.category.color,
        width: 24,
        height: 24,
      ),
      title: Text(grocery.name),
      trailing: Text(grocery.quantity.toString()),
    );
  }
}
