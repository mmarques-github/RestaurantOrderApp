import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'order_dialog.dart'; // Import the OrderDialog
import 'user_model.dart';
import 'add_item_dialog.dart'; // Import the AddItemDialog
import 'add_table_dialog.dart'; // Import the AddTableDialog
import 'preferences.dart'; // Import the Preferences
import 'waiter_screen.dart'; // Import the WaiterScreen
import 'package:collection/collection.dart';

const Color pendingColor = Colors.yellow;
const Color preparingColor = Colors.orange;
const Color readyColor = Colors.green;
const Color deliveredColor = Colors.grey;
const Color delayedColor = Colors.red;

class KitchenScreen extends StatefulWidget {
  @override
  _KitchenScreenState createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  String? username;
  String selectedMenuType = 'Daily';
  String searchQuery = '';
  Stream<QuerySnapshot> itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
  List<QueryDocumentSnapshot>? items;
  Timer? _timer;
  bool isKitchenScreen = true;
  bool groupByItem = false;

  // **Add these variables for the toggles**
  bool showTableOrders = true;
  bool showTakeawayOrders = true;

  @override
  void initState() {
    super.initState();
    loadUsername();
    _loadMenuType();
    _loadPreferences(); // Load saved preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    itemsStream.listen((snapshot) {
      setState(() {
        items = snapshot.docs;
      });
    });

    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      setState(() {});
    });
  }

  Future<void> loadUsername() async {
    String? storedUsername = await Preferences.getUsername();
    setState(() {
      username = storedUsername;
    });
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

  // **Load preferences for the toggles**
  Future<void> _loadPreferences() async {
    showTableOrders = await Preferences.getShowTableOrders();
    showTakeawayOrders = await Preferences.getShowTakeawayOrders();
    groupByItem = await Preferences.getGroupByItem();
    setState(() {});
  }

  void _toggleScreen() {
    setState(() {
      isKitchenScreen = !isKitchenScreen;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isKitchenScreen ? 'Kitchen Screen' : 'Waiter Screen'),
        actions: [
          ToggleButtons(
            children: <Widget>[
              Icon(Icons.kitchen),
              Icon(Icons.person),
            ],
            isSelected: [isKitchenScreen, !isKitchenScreen],
            onPressed: (int index) {
              _toggleScreen();
              if (!isKitchenScreen) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WaiterScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => KitchenScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Side: Orders
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // **Add the new toggles**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Show Table Orders'),
                      Switch(
                        value: showTableOrders,
                        onChanged: (value) async {
                          await Preferences.setShowTableOrders(value);
                          setState(() {
                            showTableOrders = value;
                          });
                        },
                      ),
                      SizedBox(width: 16),
                      Text('Show Takeaway Orders'),
                      Switch(
                        value: showTakeawayOrders,
                        onChanged: (value) async {
                          await Preferences.setShowTakeawayOrders(value);
                          setState(() {
                            showTakeawayOrders = value;
                          });
                        },
                      ),
                      SizedBox(width: 16),
                      Text('Group by Item'),
                      Switch(
                        value: groupByItem,
                        onChanged: (value) async {
                          await Preferences.setGroupByItem(value);
                          setState(() {
                            groupByItem = value;
                          });
                        },
                      ),
                    ],
                  ),
                  // Expanded Orders List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No orders found'));
                        }

                        var orders = snapshot.data!.docs;

                        // Filter out 'delivered' and 'cancelled' orders
                        orders = orders.where((order) => order['orderStatus'] != 'delivered' && order['orderStatus'] != 'cancelled').toList();

                        // **Apply filters based on the toggles**
                        if (!showTableOrders) {
                          orders = orders.where((order) => order['orderType'] != 'table').toList();
                        }
                        if (!showTakeawayOrders) {
                          orders = orders.where((order) => order['orderType'] != 'takeaway').toList();
                        }

                        if (groupByItem) {
                          // Grouping Logic
                          var ordersByItemId = <int, List<QueryDocumentSnapshot>>{};
                          for (var order in orders) {
                            int itemId = order['itemId'];
                            if (!ordersByItemId.containsKey(itemId)) {
                              ordersByItemId[itemId] = [];
                            }
                            ordersByItemId[itemId]!.add(order);
                          }

                          var groupedOrders = ordersByItemId.entries.toList();

                          return ListView.builder(
                            itemCount: groupedOrders.length,
                            itemBuilder: (context, index) {
                              var entry = groupedOrders[index];
                              var itemId = entry.key;
                              var ordersList = entry.value;
                              num totalPortions = ordersList.fold(
                                  0,
                                  (sum, order) =>
                                      sum + (order['orderPortion'] as num));
                              var selectedItem = items?.firstWhere(
                                  (item) => (item.data() as Map<String, dynamic>)['itemId'] == itemId);
                              String itemName = selectedItem != null
                                  ? (selectedItem.data() as Map<String, dynamic>)['itemName']
                                  : 'Unknown';

                              return GroupedOrderCard(
                                itemId: itemId.toString(),
                                itemName: itemName,
                                totalPortions: totalPortions.toInt(), // Convert to int
                                orders: ordersList,
                                items: items,
                              );
                            },
                          );
                        } else {
                          // Individual Orders Logic
                          orders.sort((a, b) {
                            var orderTypeA = a['orderType'];
                            var orderTypeB = b['orderType'];
                            var timeA = orderTypeA == 'table' ? a['orderTime'] : a['deliveryTime'];
                            var timeB = orderTypeB == 'table' ? b['orderTime'] : b['deliveryTime'];

                            if (timeA == null || timeA == "" || timeB == null || timeB == "") {
                              return 0;
                            }
                            return (timeA).compareTo(timeB);
                          });

                          return ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              var order = orders[index];
                              return OrderCard(
                                order: order,
                                items: items,
                                orderNumber: index + 1,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Right Side: Menu Items and Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Menu Type Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedMenuType = 'Daily';
                            _saveMenuType(selectedMenuType);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMenuType == 'Daily'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text('Daily'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedMenuType = 'Fixed';
                            _saveMenuType(selectedMenuType);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMenuType == 'Fixed'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text('Fixed'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedMenuType = 'Sunday';
                            _saveMenuType(selectedMenuType);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMenuType == 'Sunday'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text('Sunday'),
                      ),
                    ],
                  ),
                  // Search Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Items',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  // Menu Items List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('items')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var items = snapshot.data!.docs.where((item) {
                          var itemData = item.data() as Map<String, dynamic>;
                          return itemData['itemMenu'] == selectedMenuType &&
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
                            return ListTile(
                              title: Text(menuItem['itemName']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Delete Item'),
                                        content: Text(
                                            'Are you sure you want to delete this item?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              menuItem.reference.delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  // Add Order Button
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return OrderDialog(
                            onOrderAdded: () {
                              // Perform any additional actions if needed
                            },
                            selectedMenuType:
                                selectedMenuType, // Pass the selected menu type
                          );
                        },
                      );
                    },
                    child: Text('Add order'),
                  ),
                  SizedBox(height: 16),
                  // Add Menu Item Button
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
                    child: Text('Add menu item'),
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
                    child: Text('Add table'),
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

class GroupedOrderCard extends StatefulWidget {
  final String itemId;
  final String itemName;
  final int totalPortions;
  final List<QueryDocumentSnapshot> orders;
  final List<QueryDocumentSnapshot>? items;

  const GroupedOrderCard({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.totalPortions,
    required this.orders,
    required this.items,
  }) : super(key: key);

  @override
  _GroupedOrderCardState createState() => _GroupedOrderCardState();
}

class _GroupedOrderCardState extends State<GroupedOrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Determine card color based on the worst status
    Color cardColor = readyColor;
    Duration maxDelay = Duration.zero;
    String worstStatus = 'ready';

    for (var order in widget.orders) {
      Timestamp? orderTime = order['orderTime'] as Timestamp?;
      Timestamp? deliveryTime = order['deliveryTime'] as Timestamp?;
      Duration delay = Duration.zero;

      if (order['orderType'] == 'table') {
        if (orderTime != null && orderTime != "") {
          delay = DateTime.now().difference(orderTime.toDate());
        }
      } else {
        if (deliveryTime != null && deliveryTime != "") {
          delay = DateTime.now().difference(deliveryTime.toDate());
        }
      }

      if (delay.inMinutes < 0) {
        delay = Duration.zero;
      }
      if (delay > maxDelay) {
        maxDelay = delay;
      }
      String status = order['orderStatus'];
      if (status == 'pending' && worstStatus != 'delayed') {
        worstStatus = 'pending';
      } else if (status == 'preparing' &&
          worstStatus != 'delayed' &&
          worstStatus != 'pending') {
        worstStatus = 'preparing';
      } else if (status == 'ready' && worstStatus == 'ready') {
        worstStatus = 'ready';
      }
    }

    if (maxDelay.inMinutes > 30) {
      cardColor = delayedColor;
    } else {
      if (worstStatus == 'pending') {
        cardColor = pendingColor;
      } else if (worstStatus == 'preparing') {
        cardColor = preparingColor;
      } else if (worstStatus == 'ready') {
        cardColor = readyColor;
      }
    }

    String totalPortionText =
        widget.totalPortions == widget.totalPortions.toInt()
            ? widget.totalPortions.toInt().toString()
            : widget.totalPortions.toStringAsFixed(1);

    return Card(
      color: cardColor,
      child: Column(
        children: [
          ListTile(
            title: Text('$totalPortionText x ${widget.itemName}'),
            trailing: IconButton(
              icon:
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                children: widget.orders.map((order) {
                  return OrderCard(
                    order: order,
                    items: widget.items,
                    orderNumber: 0,
                    isGrouped: true,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;
  final int orderNumber;
  final List<QueryDocumentSnapshot>? items;
  final bool isGrouped;

  const OrderCard({
    Key? key,
    required this.order,
    required this.items,
    required this.orderNumber,
    this.isGrouped = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timestamp? orderTime = order['orderTime'] as Timestamp?;
    Timestamp? deliveryTime = order['deliveryTime'] as Timestamp?;
    Duration delay = Duration.zero;

    if (order['orderType'] == 'table') {
    if (orderTime != null && orderTime != "") {
        delay = DateTime.now().difference(orderTime.toDate());
      }
    } else {
      if (deliveryTime != null && deliveryTime != "") {
        delay = DateTime.now().difference(deliveryTime.toDate());
      }
    }

    if (delay.inMinutes < 0) {
      delay = Duration.zero;
    }

    QueryDocumentSnapshot<Object?>? selectedItem = items?.firstWhereOrNull(
      (item) =>
          (item.data() as Map<String, dynamic>)['itemId'] == order['itemId'],
    );

    String itemName = selectedItem != null
        ? (selectedItem.data() as Map<String, dynamic>)['itemName']
        : 'Unknown';
    String orderTypeString = order['orderType'] == 'takeaway'
        ? '${order['takeawayName']}'
        : '${order['tableId']}';
    String orderTimeString = 'Unknown Time';
    if (order['orderType'] == 'table') {
      if (orderTime != null) {
        orderTimeString =
            'Order Time: ${orderTime.toDate().toString().split('.')[0]}';
      }
    } else {
      if (deliveryTime != null) {
        orderTimeString =
            'Delivery Time: ${deliveryTime.toDate().toString().split('.')[0]}';
      }
    }
    num orderPortion = order['orderPortion'];
    String orderPortionText = orderPortion == orderPortion.toInt()
        ? orderPortion.toInt().toString()
        : orderPortion.toStringAsFixed(1);

    // Determine the color based on order status and delay
    Color cardColor;
    if (order['orderStatus'] == 'pending') {
      cardColor = pendingColor;
    } else if (order['orderStatus'] == 'preparing') {
      cardColor = preparingColor;
    } else if (order['orderStatus'] == 'ready') {
      cardColor = readyColor;
    } else {
      cardColor = deliveredColor;
    }

    if (delay.inMinutes > 30) {
      cardColor = delayedColor;
    }

    Widget cardContent = Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('${orderPortionText} x $itemName'),
                ),
                Expanded(
                  flex: 1,
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where('id', isEqualTo: order['userId'])
                        .limit(1)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Text('Loading user...');
                      }
                      if (snapshot.hasError) {
                        return Text('Error loading user');
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Text('User not found');
                      }
                      var userData = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      String username = userData['name'];
                      return Text('$orderTypeString - $username');
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(orderTimeString),
                ),
                if (!isGrouped)
                  Expanded(
                    flex: 1,
                    child: Text('Order $orderNumber'),
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Order'),
                          content:
                              Text('Are you sure you want to delete this order?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                order.reference.delete();
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Details: ${order['orderDetails']}'),
                Text('Delay: ${delay.inMinutes} minutes'),
              ],
            ),
          ],
        ),
      ),
    );

    if (isGrouped) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}

