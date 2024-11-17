import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'preferences.dart'; // Import the Preferences

class OrderDialog extends StatefulWidget {
  final VoidCallback onOrderAdded;
  final String selectedMenuType; // Add selectedMenuType parameter
  final String? preselectedTableId; // Add this parameter

  OrderDialog({
    required this.onOrderAdded,
    required this.selectedMenuType,
    this.preselectedTableId, // Add this parameter
  });

  @override
  _OrderDialogState createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  String tableId = '';
  String orderType = 'table';
  String orderDetails = '';
  Map<String, int> itemPortions = {}; // Use String for itemId and int for portions
  DateTime? deliveryDate;
  TimeOfDay? deliveryTime;
  String searchQuery = '';
  late String itemMenuFilter;
  TextEditingController searchController = TextEditingController();
  String takeawayName = ''; // Add takeawayName variable
  String? username;
  int? userId; // Declare userId as nullable integer
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadUsername();
    itemMenuFilter = widget.selectedMenuType.toLowerCase(); // Initialize with the passed menu type
    if (widget.preselectedTableId != null) {
      tableId = widget.preselectedTableId!;
      orderType = 'table'; // Force table order type if table is preselected
    }
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  Future<void> loadUsername() async {
    String? storedUsername = await Preferences.getUsername();
    if (storedUsername != null) {
      setState(() {
        username = storedUsername;
      });
      await fetchUserId();
    } else {
      // Handle the case where username is not set
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username not found in preferences')),
      );
      // Optionally, navigate back or prompt for login
    }
  }

  Future<void> fetchUserId() async {
    print('Fetching userId');
    if (username == null) {
      // Username not loaded yet
      print('Username not loaded yet');
      return;
    }

    try {
      // Query the 'users' collection where 'username' matches
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userId = userData['id'] as int;
          print('UserId $userId');
        });
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching userId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user information')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuType(String menuType) async {
    await Preferences.setSelectedMenuType(menuType);
  }

  final Color buttonBackgroundDefaultColor = Colors.grey.shade200;
  final Color buttonBackgroundSelectedColor = Colors.purple.shade200;
  final Color buttonOutlineDefaultColor = Colors.grey.shade900;
  final Color buttonOutlineSelectedColor = Colors.purple.shade200;

  Widget _buildMenuButtons() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'daily';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                        itemMenuFilter == 'daily' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'daily' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Daily'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'fixed';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'fixed' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'fixed' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Fixed'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'sunday';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'sunday' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'sunday' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Sunday'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'entree';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'entree' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'entree' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Entree'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'dessert';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'dessert' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'dessert' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Dessert'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'drink';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'drink' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'drink' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Drink'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'cafeteria';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'cafeteria' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'cafeteria' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Cafeteria'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        itemMenuFilter = 'spirits';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemMenuFilter == 'spirits' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                      side: BorderSide(
                        color: itemMenuFilter == 'spirits' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                      ),
                    ),
                    child: Text('Spirits'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Order'),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent overflow by setting to min
          children: [
            // Your widget children go here
            TextField(
              controller: searchController,
                decoration: InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 16),
              // Menu Type Selection Buttons
              _buildMenuButtons(),
              SizedBox(height: 16),
              // User Information
              SizedBox(height: 16),
              // Expanded ListView
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var items = snapshot.data!.docs.where((item) {
                    var itemData = item.data() as Map<String, dynamic>;
                    var itemMenu =
                        itemData['itemMenu'].toString().toLowerCase();
                    var itemType =
                        itemData['itemType'].toString().toLowerCase();
                    return (itemMenu == itemMenuFilter ||
                            itemType == itemMenuFilter) &&
                        (itemData['itemName'] as String)
                            .toLowerCase()
                            .contains(searchQuery);
                  }).toList();

                  // Sort items alphabetically by itemName
                  items.sort((a, b) {
                    var itemNameA =
                        (a.data() as Map<String, dynamic>)['itemName'];
                    var itemNameB =
                        (b.data() as Map<String, dynamic>)['itemName'];
                    return itemNameA.compareTo(itemNameB);
                  });

                  if (items.isEmpty) {
                    return Center(child: Text('No menu items found'));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var menuItem = items[index];
                      var menuItemData =
                          menuItem.data() as Map<String, dynamic>;
                      var itemId = menuItem.id;
                      var itemName = menuItemData['itemName'] ?? 'Unknown';
                      var currentPortion = itemPortions[itemId] ?? 0;

                      return ListTile(
                        title: Text(itemName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (currentPortion > 0) {
                                    // Decrease the portion by 1
                                    itemPortions[itemId] = currentPortion - 1;
                                  }
                                });
                              },
                            ),
                            Text(currentPortion.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  // Increase the portion by 1
                                  itemPortions[itemId] = currentPortion + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Additional Options and Buttons
            SingleChildScrollView(
              child: Column(
                children: [
                  // Order Type Selection Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            orderType = 'table';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              orderType == 'table' ? buttonBackgroundSelectedColor : buttonBackgroundDefaultColor,
                          side: BorderSide(
                            color: orderType == 'table' ? buttonOutlineSelectedColor : buttonOutlineDefaultColor,
                          ),
                        ),
                        child: Text('Table'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            orderType = 'takeaway';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orderType == 'takeaway'
                              ? buttonBackgroundSelectedColor
                              : buttonBackgroundDefaultColor,
                          side: BorderSide(
                            color: orderType == 'takeaway'
                                ? buttonOutlineSelectedColor
                                : buttonOutlineDefaultColor,
                          ),
                        ),
                        child: Text('Takeaway'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (orderType == 'table') ...[
                    widget.preselectedTableId != null
                        ? Text('Table: ${widget.preselectedTableId}')
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('tables').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return CircularProgressIndicator();
                              
                              List<DropdownMenuItem<String>> tableItems = snapshot.data!.docs
                                  .map((doc) => DropdownMenuItem<String>(
                                        child: Text(doc.id),
                                        value: doc.id,
                                      ))
                                  .toList();
                              
                              return DropdownButtonFormField<String>(
                                hint: Text("Select Table"),
                                items: tableItems,
                                value: tableId.isNotEmpty ? tableId : null,
                                onChanged: widget.preselectedTableId != null ? null : (value) {
                                  if (value != null) {
                                    setState(() {
                                      tableId = value;
                                    });
                                  }
                                },
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Table',
                                  suffixIcon: Icon(Icons.table_chart),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 16),
                  ],
                  if (orderType == 'takeaway') ...[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Takeaway Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          takeawayName = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365 * 100)), // Check if the change to this line is bug free
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              deliveryDate = pickedDate;
                              deliveryTime = pickedTime;
                            });
                          }
                        }
                      },
                      child: Text('Select Delivery Time'),
                    ),
                    if (deliveryDate != null && deliveryTime != null)
                      Text(
                          'Delivery Time: ${deliveryDate!.toLocal().toString().split(' ')[0]} ${deliveryTime!.format(context)}'),
                  ],
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Order details",
                    ),
                    onChanged: (value) {
                      setState(() {
                        orderDetails = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Validate that userId is fetched
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User information not loaded')),
                          );
                          return;
                        }

                        // Previous validation checks...
                        if (itemPortions.isEmpty || itemPortions.values.every((portion) => portion == 0)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select at least one item')),
                          );
                          return;
                        }

                        if (orderType == 'table' && tableId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a table')),
                          );
                          return;
                        }

                        if (orderType == 'takeaway' && takeawayName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a takeaway name')),
                          );
                          return;
                        }

                        // Get next order number
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                            .collection('orders')
                            .orderBy('orderId', descending: true)
                            .limit(1)
                            .get();

                        int nextOrderNumber = 1;
                        if (querySnapshot.docs.isNotEmpty) {
                          nextOrderNumber = (querySnapshot.docs.first['orderId'] as int) + 1;
                        }

                        // Add the orders to the database
                        for (var itemId in itemPortions.keys) {
                          int portion = itemPortions[itemId]!;
                          if (portion > 0) {
                            // Fetch the item document to get the numeric itemId and itemName
                            DocumentSnapshot itemDoc = await FirebaseFirestore.instance
                                .collection('items')
                                .doc(itemId)
                                .get();

                            if (!itemDoc.exists) {
                              throw Exception('Item not found: $itemId');
                            }

                            var itemData = itemDoc.data() as Map<String, dynamic>;
                            int numericItemId = itemData['itemId'] as int;
                            String itemName = itemData['itemName'] as String;

                            // Generate unique orderId
                            String orderId = 'order${nextOrderNumber}';

                            // Create the order document
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(orderId)
                                .set({
                                  'orderId': nextOrderNumber,
                                  'tableId': orderType == 'table' ? tableId : null,
                                  'orderType': orderType,
                                  'orderTime': FieldValue.serverTimestamp(),
                                  'orderDetails': orderDetails,
                                  'itemId': numericItemId,
                                  'orderPortion': portion,
                                  'orderStatus': 'pending',
                                  'userId': userId, // Use the fetched userId
                                  'takeawayName': orderType == 'takeaway' ? takeawayName : null,
                                  'deliveryTime': orderType == 'takeaway' 
                                      ? Timestamp.fromDate(DateTime(
                                          deliveryDate!.year,
                                          deliveryDate!.month,
                                          deliveryDate!.day,
                                          deliveryTime!.hour,
                                          deliveryTime!.minute,
                                        ))
                                      : null,
                                });

                            nextOrderNumber++;
                          }
                        }

                        widget.onOrderAdded();
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error adding order: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding order: $e')),
                        );
                      }
                    },
                    child: Text('Add Order'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
