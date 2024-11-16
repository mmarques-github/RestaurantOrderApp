import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String tableNumber;
  final String orderDetails;
  final DateTime orderTime;
  final String status;

  Order({required this.tableNumber, required this.orderDetails, required this.orderTime, required this.status});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      tableNumber: json['tableNumber'],
      orderDetails: json['orderDetails'],
      orderTime: (json['orderTime'] as Timestamp).toDate(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'orderDetails': orderDetails,
      'orderTime': orderTime,
      'status': status,
    };
  }
}
