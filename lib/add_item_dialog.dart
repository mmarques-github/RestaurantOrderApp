import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemDialog extends StatefulWidget {
  final VoidCallback onItemAdded;

  AddItemDialog({required this.onItemAdded});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  bool itemAvailable = true;
  String itemMenu = 'Fixed';
  String itemName = '';
  String itemType = 'main';
  final List<String> itemTypes = ['entree', 'dessert', 'main', 'drink', 'cafeteria', 'spirits'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CheckboxListTile(
                title: Text('Item Available'),
                value: itemAvailable,
                onChanged: (value) {
                  setState(() {
                    itemAvailable = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: itemType,
                decoration: InputDecoration(labelText: 'Item Type'),
                items: itemTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    itemType = newValue!;
                  });
                },
              ),
              if (itemType == 'main') ...[
                DropdownButtonFormField<String>(
                  value: itemMenu,
                  decoration: InputDecoration(labelText: 'Item Menu'),
                  items: ['Daily', 'Fixed', 'Sunday'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      itemMenu = newValue!;
                    });
                  },
                ),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    itemName = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await FirebaseFirestore.instance.collection('items').add({
                'itemName': itemName,
                'itemType': itemType,
                'itemMenu': itemType == 'main' ? itemMenu : null,
                'availability': itemAvailable ? 'available' : 'unavailable',
              });
              widget.onItemAdded();
              Navigator.of(context).pop();
            }
          },
          child: Text('Add Item'),
        ),
      ],
    );
  }
}