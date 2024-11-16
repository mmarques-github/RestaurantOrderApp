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
  final List<String> itemTypes = ['entree', 'dessert', 'main', 'drink'];

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
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                onSaved: (value) {
                  itemName = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: itemMenu,
                decoration: InputDecoration(labelText: 'Item Menu'),
                items: ['Fixed', 'Daily', 'Sunday'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    itemMenu = value!;
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
                onChanged: (value) {
                  setState(() {
                    itemType = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addItem(),
                child: Text('Add Item'),
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
      ],
    );
  }

  void _addItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Fetch the current highest itemId
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('items')
            .orderBy('itemId', descending: true)
            .limit(1)
            .get();

        int nextItemId = 1;
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          nextItemId = (documentSnapshot['itemId'] as int) + 1;
        }

        String itemId = 'item$nextItemId';

        // Add the new item with the next itemId
        await FirebaseFirestore.instance.collection('items').doc(itemId).set({
          'itemAvailable': itemAvailable,
          'itemId': nextItemId,
          'itemMenu': itemMenu,
          'itemName': itemName,
          'itemType': itemType,
        });

        widget.onItemAdded();
        Navigator.of(context).pop();
      } catch (e) {
        print('Error adding item: $e');
      }
    }
  }
}