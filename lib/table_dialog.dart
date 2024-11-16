import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'order_dialog.dart';
import 'preferences.dart'; // Import Preferences

class TableDialog extends StatefulWidget {
  final String tableId;
  final VoidCallback onOrderAdded;
  final String selectedMenuType; // Add selectedMenuType

  const TableDialog({
    Key? key,
    required this.tableId,
    required this.onOrderAdded,
    required this.selectedMenuType, // Add selectedMenuType
  }) : super(key: key);

  @override
  _TableDialogState createState() => _TableDialogState();
}

final states = ['pending', 'preparing', 'ready', 'delivered', 'payed'];

class _TableDialogState extends State<TableDialog> {
  String? username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    String? storedUsername = await Preferences.getUsername();
    setState(() {
      username = storedUsername;
    });
  }

  // Function to update order status
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'orderStatus': newStatus});
  }

  // Function to move order state forward
  Future<void> _moveOrderForward(String orderId, String currentStatus) async {
    final currentIndex = states.indexOf(currentStatus);
    if (currentIndex < states.length - 1) {
      await _updateOrderStatus(orderId, states[currentIndex + 1]);
    }
  }

  // Function to move order state backward
  Future<void> _moveOrderBackward(String orderId, String currentStatus) async {
    final currentIndex = states.indexOf(currentStatus);
    if (currentIndex > 0) { // Only allow moving back after 'preparing'
      await _updateOrderStatus(orderId, states[currentIndex - 1]);
    }
  }

  // Function to show delete confirmation
  Future<void> _showDeleteConfirmation(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
    }
  }

  Future<void> _clearTable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear Table'),
          content: const Text('Are you sure you want to delete all orders for this table?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear Table'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final orders = await FirebaseFirestore.instance
          .collection('orders')
          .where('tableId', isEqualTo: widget.tableId)
          .get();

      for (var order in orders.docs) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .delete();
      }

      Navigator.of(context).pop(); // Close the dialog after clearing the table
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = deviceWidth < 400;

    // Define font size constants relative to device size
    final double dialogTitleFontSize = deviceWidth * 0.05;
    final double buttonFontSize = deviceWidth * 0.04;
    final double paddingVertical = deviceHeight * 0.005; // Reduced padding
    final double paddingHorizontal = deviceWidth * 0.02;
    final double iconButtonSize = isSmallScreen ? 18 : 24; // Smaller size for small screens

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Table ${widget.tableId}',
            style: TextStyle(fontSize: dialogTitleFontSize),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: deviceHeight * 0.5, // Reduced height for better fit
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('tableId', isEqualTo: widget.tableId)
              .where('orderType', isEqualTo: 'table')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return const Center(child: Text('No orders for this table'));
            }

            // Sort orders by delay and status
            orders.sort((a, b) {
              var timeA = ((a.data() as Map<String, dynamic>)['orderTime'] as Timestamp?) ?? Timestamp.now();
              var timeB = ((b.data() as Map<String, dynamic>)['orderTime'] as Timestamp?) ?? Timestamp.now();
              
              var delayA = DateTime.now().difference(timeA.toDate());
              var delayB = DateTime.now().difference(timeB.toDate());
              
              var delayComparison = delayB.compareTo(delayA);
              if (delayComparison != 0) {
                return delayComparison;
              }
              
              var statusA = (a.data() as Map<String, dynamic>)['orderStatus'] as String;
              var statusB = (b.data() as Map<String, dynamic>)['orderStatus'] as String;
              return states.indexOf(statusA) - states.indexOf(statusB);
            });

            return ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderData = order.data() as Map<String, dynamic>;
                var orderStatus = orderData['orderStatus'];
                var orderTime = ((orderData['orderTime'] as Timestamp?) ?? Timestamp.now()).toDate();
                var orderColor = _getStatusColor(orderStatus, orderTime);

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('items')
                      .where('itemId', isEqualTo: orderData['itemId'])
                      .limit(1)
                      .get(),
                  builder: (context, itemSnapshot) {
                    if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
                      return Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: paddingVertical,
                            horizontal: paddingHorizontal,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${orderData['orderPortion']} x Unknown Item',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    var itemDoc = itemSnapshot.data!.docs.first;
                    var itemData = itemDoc.data() as Map<String, dynamic>;
                    var itemName = itemData['itemName'] ?? 'Unknown Item';

                    return Card(
                      color: orderColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: paddingVertical,
                          horizontal: paddingHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column for Text Elements
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Portions x ItemName
                                Text(
                                  '${orderData['orderPortion']} x $itemName',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 12.0 : 16.0,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: paddingVertical * 0.5),

                                // OrderStatus (username)
                                Text(
                                  '${orderStatus.toUpperCase()} (${username ?? 'Unknown User'})',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: paddingVertical * 0.5),

                                // Delay - OrderDetails
                                Text(
                                  '${calculateDelay(orderTime)} - ${orderData['orderDetails'] ?? ''}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            SizedBox(height: paddingVertical * 0.5), // Spacing between text and buttons

                            // Row for Button Elements
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Move Back Button
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: orderStatus != states.first
                                      ? () => _moveOrderBackward(order.id, orderStatus)
                                      : null,
                                  iconSize: iconButtonSize,
                                  tooltip: 'Move Back',
                                ),

                                // Move Forward Button
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: orderStatus != states.last
                                      ? () => _moveOrderForward(order.id, orderStatus)
                                      : null,
                                  iconSize: iconButtonSize,
                                  tooltip: 'Move Forward',
                                ),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteConfirmation(context, order.id),
                                  iconSize: iconButtonSize,
                                  tooltip: 'Delete Order',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _clearTable,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100, // Red background for the clear table button
          ),
          child: Text(
            'Clear Table',
            style: TextStyle(fontSize: buttonFontSize),
          ),
        ),
        ElevatedButton(
          onPressed: _openOrderDialog,
          child: Text(
            'Add Order',
            style: TextStyle(fontSize: buttonFontSize),
          ),
        ),
      ],
    );
  }

  void _openOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderDialog(
          onOrderAdded: widget.onOrderAdded,
          selectedMenuType: widget.selectedMenuType,
          preselectedTableId: widget.tableId,
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  String calculateDelay(DateTime dateTime) {
    var diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    else if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    else return '${diff.inDays}d ${diff.inHours.remainder(24)}h';
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
}
