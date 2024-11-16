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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Table ${widget.tableId}'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('tableId', isEqualTo: widget.tableId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return const Center(child: Text('No orders for this table'));
            }

            // Sort orders by status and time
            orders.sort((a, b) {
              var statusA = (a.data() as Map<String, dynamic>)['orderStatus'] as String;
              var statusB = (b.data() as Map<String, dynamic>)['orderStatus'] as String;
              var timeA = (a.data() as Map<String, dynamic>)['orderTime'] as Timestamp;
              var timeB = (b.data() as Map<String, dynamic>)['orderTime'] as Timestamp;

              if (statusA != statusB) {
                // Custom status ordering
                final statusOrder = ['pending', 'preparing', 'ready', 'delivered'];
                return statusOrder.indexOf(statusA) - statusOrder.indexOf(statusB);
              }
              return timeB.compareTo(timeA); // Newer orders first
            });

            return ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderData = order.data() as Map<String, dynamic>;
                var orderStatus = orderData['orderStatus'];
                var orderTime = (orderData['orderTime'] as Timestamp).toDate();
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
                        child: ListTile(
                          title: Text('${orderData['orderPortion'].toString()} x Unknown Item'),
                        ),
                      );
                    }

                    var itemDoc = itemSnapshot.data!.docs.first;
                    var itemData = itemDoc.data() as Map<String, dynamic>;
                    var itemName = itemData['itemName'] ?? 'Unknown Item';

                    return Card(
                      color: orderColor,
                      child: ListTile(
                        title: Text('${orderData['orderPortion'].toString()} x $itemName - ${calculateDelay(orderTime)}'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Status: ${orderStatus.toUpperCase()}'),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('id', isEqualTo: orderData['userId'])
                                  .limit(1)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                                  return const Text('Unknown User');
                                }
                                var userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                var userName = userData['name'] ?? 'Unknown User';
                                return Text('$userName');
                              },
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _openOrderDialog,
          child: const Text('Add Order'),
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
      // Refresh the table dialog when returning from the order dialog
      setState(() {});
    });
  }

  String calculateDelay(DateTime dateTime) {
    var diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    else if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ago'; // print hh:mm if less than 24 hours  
    else return '${diff.inDays}d ${diff.inHours.remainder(24)}h ago'; // print dd:hh if more than 24 hours
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