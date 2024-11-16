import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTableDialog extends StatelessWidget {
  final TextEditingController _tableNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Table'),
      content: TextField(
        controller: _tableNameController,
        decoration: InputDecoration(labelText: 'Table Name'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_tableNameController.text.isNotEmpty) {
              FirebaseFirestore.instance.collection('tables').add({
                'tableName': _tableNameController.text,
                'createdAt': Timestamp.now(),
              });
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}