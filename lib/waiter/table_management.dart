import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableManagement extends StatelessWidget {
  final TextEditingController tableNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Table Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tableNumberController,
              decoration: InputDecoration(labelText: 'Table Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addTable(),
              child: Text('Add Table'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('tables').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var tables = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      var table = tables[index];
                      return ListTile(
                        title: Text('Table ${table['number']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTable(table.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTable() {
    if (tableNumberController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('tables').add({
        'number': tableNumberController.text,
      });
      tableNumberController.clear();
    }
  }

  void _deleteTable(String tableId) {
    FirebaseFirestore.instance.collection('tables').doc(tableId).delete();
  }
}
