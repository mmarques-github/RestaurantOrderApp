import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kitchen_screen.dart'; // Import the KitchenScreen
import 'add_item_dialog.dart';
import 'add_table_dialog.dart';
import 'order_dialog.dart';
import 'table_dialog.dart'; // Import the TableDialog
import 'preferences.dart'; // Import the Preferences class
import 'user_model.dart'; // Import the UserModel
import 'package:provider/provider.dart'; // Import the provider package

class WaiterScreen extends StatefulWidget {
  @override
  _WaiterScreenState createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  String selectedMenuType = 'Daily'; // Default selected menu type
  final TextEditingController tableController = TextEditingController();
  final TextEditingController orderController = TextEditingController();
  final CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  bool isKitchenScreen = false; // Track the current screen
  String searchQuery = ''; // Search query for filtering items
  Set<String> selectedPrefixes = {};  // Track selected prefix filters
  String? username;

  @override
  void initState() {
    super.initState();
    _loadMenuType();
    loadUsername();
  }

  Future<void> _loadMenuType() async {
    final menuType = await Preferences.getSelectedMenuType();
    setState(() {
      selectedMenuType = menuType;
    });
  }

  Future<void> _saveMenuType(String menuType) async {
    await Preferences.setSelectedMenuType(menuType);
  }

  Future<void> loadUsername() async {
    String? storedUsername = await Preferences.getUsername();
    setState(() {
      username = storedUsername;
    });
  }

  void _toggleScreen() {
    setState(() {
      isKitchenScreen = !isKitchenScreen;
    });
  }

  Widget _buildPrefixFilters() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tables').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        // Extract unique prefixes from table names
        Set<String> prefixes = snapshot.data!.docs.map((doc) {
          String tableName = doc.id;
          return tableName.replaceAll(RegExp(r'[0-9]'), ''); // Remove numbers
        }).toSet();

        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: prefixes.map((prefix) {
            return FilterChip(
              label: Text(prefix),
              selected: selectedPrefixes.contains(prefix),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedPrefixes.add(prefix);
                  } else {
                    selectedPrefixes.remove(prefix);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Waiter Screen'),
        actions: [
          ToggleButtons(
            children: <Widget>[
              Icon(Icons.kitchen),
              Icon(Icons.person),
            ],
            isSelected: [isKitchenScreen, !isKitchenScreen],
            onPressed: (int index) {
              _toggleScreen();
              if (isKitchenScreen) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => KitchenScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WaiterScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPrefixFilters(), // Add the filter buttons
            SizedBox(height: 16),
            // Search Field (Optional)
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Tables',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16),
            // Expanded Widget to Display Tables and Orders
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('tables').snapshots(),
                builder: (context, tableSnapshot) {
                  if (!tableSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var tables = tableSnapshot.data!.docs;

                  // Filter tables if prefixes are selected
                  if (selectedPrefixes.isNotEmpty) {
                    tables = tables.where((table) {
                      String prefix = table.id.replaceAll(RegExp(r'[0-9]'), '');
                      return selectedPrefixes.contains(prefix);
                    }).toList();
                  }

                  // Fetch the items collection
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('items').snapshots(),
                    builder: (context, itemSnapshot) {
                      if (!itemSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      var items = itemSnapshot.data!.docs;

                      return ListView.builder(
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          var table = tables[index];
                          var tableData = table.data() as Map<String, dynamic>;

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('tableId', isEqualTo: table.id)
                                .snapshots(),
                            builder: (context, orderSnapshot) {
                              if (!orderSnapshot.hasData) {
                                return Card(
                                  color: Colors.green.shade100, // Default color for no orders
                                  child: ListTile(
                                    title: Text('${table.id}'),
                                    subtitle: Text('No orders'),
                                  ),
                                );
                              }
                              var orders = orderSnapshot.data!.docs;

                              // Determine the table color based on order statuses
                              Color tableColor = Colors.green.shade100; // Default color for no orders
                              bool hasPendingOrPreparing = false;
                              bool hasReady = false;
                              bool allDeliveredOrPayed = false;
                              bool allPayed = false;

                              for (var order in orders) {
                                var orderData = order.data() as Map<String, dynamic>;
                                var orderStatus = orderData['orderStatus'];

                                if (orderStatus == 'pending' || orderStatus == 'preparing') {
                                  hasPendingOrPreparing = true;
                                  allDeliveredOrPayed = false;
                                  allPayed = false;
                                } else if (orderStatus == 'ready') {
                                  hasReady = true;
                                  allDeliveredOrPayed = false;
                                  allPayed = false;
                                } else if (orderStatus == 'delivered' || orderStatus == 'payed') {
                                    allDeliveredOrPayed = true;
                                    allPayed = true;
                                  if (orderStatus == 'delivered') {
                                    allPayed = false;
                                  }
                                }
                              }

                              if (hasReady) {
                                tableColor = Colors.blue.shade100;
                              } else if (hasPendingOrPreparing) {
                                tableColor = Colors.orange.shade100;
                              } else if (allDeliveredOrPayed) {
                                tableColor = Colors.yellow.shade100;
                              } else if (allPayed) {
                                tableColor = Colors.grey.shade100;
                              }

                              // Limit the number of orders displayed to 5
                              var limitedOrders = orders.take(5).toList();

                              var orderDetails = limitedOrders.map((order) {
                                var orderData = order.data() as Map<String, dynamic>;

                                // Find the matching item in the items collection
                                var selectedItem = items.firstWhere(
                                  (item) =>
                                      (item.data() as Map<String, dynamic>)['itemId'] ==
                                      orderData['itemId'],
                                );

                                String itemName = selectedItem != null
                                    ? (selectedItem.data() as Map<String, dynamic>)['itemName'] ?? 'Unknown'
                                    : 'Unknown';

                                return '${orderData['orderPortion']} x $itemName (${orderData['orderStatus']})';
                              }).join(', ');

                              return Card(
                                color: tableColor,
                                child: ListTile(
                                  title: Text('${table.id}'),
                                  subtitle: Text(orderDetails),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return TableDialog(
                                          tableId: table.id,
                                          onOrderAdded: () {
                                            setState(() {
                                              // Refresh the screen
                                            });
                                          },
                                          selectedMenuType: selectedMenuType, // Pass the selected menu type
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Add Order Button
            ElevatedButton(
              onPressed: _openOrderDialog,
              child: Text('Add Order'),
            ),
            SizedBox(height: 16),
            // Add Item Button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddItemDialog(
                      onItemAdded: () {
                        setState(() {
                          // Refresh the screen
                        });
                      },
                    );
                  },
                );
              },
              child: Text('Add Item'),
            ),
            SizedBox(height: 16), 
            // Add Table Button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddTableDialog();
                  },
                );
              },
              child: Text('Add Table'),
            ),
          ],
        ),
      ),
    );
  }

  void _openOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderDialog(
          onOrderAdded: () {
            // Perform any additional actions if needed
          },
          selectedMenuType: selectedMenuType, // Pass the selected menu type
        );
      },
    );
  }
}
