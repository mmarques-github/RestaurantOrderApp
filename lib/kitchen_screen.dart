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

final states = ['pending', 'preparing', 'ready', 'delivered', 'payed'];

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
  bool showTodayOrders = false;

  double fontSize = 14.0; // Add this for font size control

  @override
  void initState() {
    super.initState();
    loadUsername();
    _loadMenuType();
    _loadPreferences(); // Load saved preferences
    _loadFontSize(); // Add this
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
    showTodayOrders = await Preferences.getShowTodayOrders();
    setState(() {});
  }

  // Add this method to load saved font size
  Future<void> _loadFontSize() async {
    final savedSize = await Preferences.getFontSize();
    setState(() {
      fontSize = savedSize;
    });
  }

  // Add this method to save font size
  Future<void> _saveFontSize(double size) async {
    await Preferences.setFontSize(size);
    setState(() {
      fontSize = size;
    });
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
          // Add font size controls before the screen toggle
          if (isKitchenScreen) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (fontSize > 8.0) {
                      _saveFontSize(fontSize - 2.0);
                    }
                  },
                ),
                Text('Font Size: ${fontSize.round()}', 
                  style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (fontSize < 32.0) {
                      _saveFontSize(fontSize + 2.0);
                    }
                  },
                ),
              ],
            ),
          ],
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
                      SizedBox(width: 16),
                      Text('Today'),
                      Switch(
                        value: showTodayOrders,
                        onChanged: (value) async {
                          await Preferences.setShowTodayOrders(value);
                          setState(() {
                            showTodayOrders = value;
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

                        // Filter out 'delivered' and 'payed' orders
                        orders = orders.where((order) => 
                          order['orderStatus'] != 'delivered' && 
                          order['orderStatus'] != 'payed'
                        ).toList();

                        // Filter out non-main items using the items list
                        orders = orders.where((order) {
                          var itemId = order['itemId'];
                          var matchingItem = items?.firstWhereOrNull(
                            (item) => (item.data() as Map<String, dynamic>)['itemId'] == itemId
                          );
                          if (matchingItem != null) {
                            var itemData = matchingItem.data() as Map<String, dynamic>;
                            return itemData['itemType'] == 'main';
                          }
                          return false;
                        }).toList();

                        // **Apply filters based on the toggles**
                        if (!showTableOrders) {
                          orders = orders.where((order) => order['orderType'] != 'table').toList();
                        }
                        if (!showTakeawayOrders) {
                          orders = orders.where((order) => order['orderType'] != 'takeaway').toList();
                        }

                        if (showTodayOrders) {
                          DateTime todayStart = DateTime.now();
                          todayStart = DateTime(todayStart.year, todayStart.month, todayStart.day);
                          orders = orders.where((order) {
                            Timestamp? timeStamp;
                            if (order['orderType'] == 'table') {
                              timeStamp = order['orderTime'] as Timestamp?;
                            } else {
                              timeStamp = order['deliveryTime'] as Timestamp?;
                            }
                            if (timeStamp != null) {
                              DateTime orderDate = timeStamp.toDate();
                              return orderDate.isAfter(todayStart);
                            } else {
                              return false;
                            }
                          }).toList();
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
                                fontSize: fontSize, // Pass the font size
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
                                fontSize: fontSize, // Pass the font size
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
                              ? Colors.purple.shade200 
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color: selectedMenuType == 'Daily'
                                ? Colors.purple.shade200
                                : Colors.grey.shade900,
                          ),
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
                              ? Colors.purple.shade200
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color: selectedMenuType == 'Fixed'
                                ? Colors.purple.shade200
                                : Colors.grey.shade900,
                          ),
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
                              ? Colors.purple.shade200
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color: selectedMenuType == 'Sunday'
                                ? Colors.purple.shade200
                                : Colors.grey.shade900,
                          ),
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
                            var isAvailable = menuItem['itemAvailable'] ?? true;
                            return ListTile(
                              title: Text(menuItem['itemName']),
                              enabled: isAvailable,
                              textColor: isAvailable 
                                  ? null 
                                  : Theme.of(context).disabledColor,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isAvailable 
                                          ? Icons.not_interested
                                          : Icons.check_circle,
                                      color: isAvailable 
                                          ? Colors.red 
                                          : Colors.green,
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('items')
                                          .doc(menuItem.id)
                                          .update({
                                        'itemAvailable': !isAvailable
                                      });
                                    },
                                  ),
                                  IconButton(
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
                                ],
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
  final double fontSize;

  const GroupedOrderCard({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.totalPortions,
    required this.orders,
    required this.items,
    this.fontSize = 14.0, // Add default value
  }) : super(key: key);

  @override
  _GroupedOrderCardState createState() => _GroupedOrderCardState();
}

class _GroupedOrderCardState extends State<GroupedOrderCard> {
  bool isExpanded = false;

  Color _getStatusColor(String status, DateTime orderTime) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'preparing':
        if (orderTime.isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
          return Colors.red.shade100;
        }
        return Colors.orange.shade100;
      case 'ready':
        return Colors.blue.shade100;
      case 'delivered':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

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
      color: _getStatusColor(worstStatus, 
          DateTime.now().subtract(maxDelay)),
      shape: widget.orders.any((order) => order['orderType'] == 'takeaway')
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Column(
        children: [
          ListTile(
            title: Text('$totalPortionText x ${widget.itemName}', 
              style: TextStyle(fontSize: widget.fontSize)),
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
                    fontSize: widget.fontSize, // Pass the font size
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
  final double fontSize;

  const OrderCard({
    Key? key,
    required this.order,
    required this.items,
    required this.orderNumber,
    this.isGrouped = false,
    this.fontSize = 14.0, // Add default value
  }) : super(key: key);

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'orderStatus': newStatus});
  }

  Future<void> _moveOrderForward(String orderId, String currentStatus) async {
    final currentIndex = states.indexOf(currentStatus);
    if (currentIndex < states.length - 1) {
      await _updateOrderStatus(orderId, states[currentIndex + 1]);
    }
  }

  Future<void> _moveOrderBackward(String orderId, String currentStatus) async {
    final currentIndex = states.indexOf(currentStatus);
    if (currentIndex > 0) {
      await _updateOrderStatus(orderId, states[currentIndex - 1]);
    }
  }

  Color _getStatusColor(String status, DateTime orderTime) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'preparing':
        if (orderTime.isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
          return Colors.red.shade100;
        }
        return Colors.orange.shade100;
      case 'ready':
        return Colors.blue.shade100;
      case 'delivered':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

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
        DateTime orderDateTime = orderTime.toDate();
        DateTime now = DateTime.now();
        if (orderDateTime.year == now.year &&
            orderDateTime.month == now.month &&
            orderDateTime.day == now.day) {
          orderTimeString = '${orderDateTime.toString().split(' ')[1].split('.')[0]}';
        } else {
          orderTimeString = '${orderDateTime.toString().split('.')[0]}';
        }
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
      color: _getStatusColor(order['orderStatus'], 
          orderTime?.toDate() ?? DateTime.now()),
      shape: order['orderType'] == 'takeaway' 
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Padding(
        // ...rest of existing card content...
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('${orderPortionText} x $itemName', 
                    style: TextStyle(fontSize: fontSize)),
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
                      return Text('$orderTypeString - $username', 
                        style: TextStyle(fontSize: fontSize));
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(orderTimeString, 
                    style: TextStyle(fontSize: fontSize)),
                ),
                if (!isGrouped)
                  Expanded(
                    flex: 1,
                    child: Text('Order ${order['orderId']}', 
                      style: TextStyle(fontSize: fontSize)),
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: order['orderStatus'] != states.first
                      ? () => _moveOrderBackward(order.id, order['orderStatus'])
                      : null,
                  iconSize: 24,
                  tooltip: 'Move Back',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward), 
                  onPressed: order['orderStatus'] != states.last
                      ? () => _moveOrderForward(order.id, order['orderStatus'])
                      : null,
                  iconSize: 24,
                  tooltip: 'Move Forward',
                ),
                // Existing delete button
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
                Text('${order['orderStatus'].toString().toUpperCase()} - ${order['orderDetails']}', 
                  style: TextStyle(fontSize: fontSize)),
                Text('Delay: ${delay.inMinutes} minutes', 
                  style: TextStyle(fontSize: fontSize)),
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

