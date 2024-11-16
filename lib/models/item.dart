class Item {
  final String id;
  final String name;
  final String menuId;
  final String type;
  final String userId;
  final String availability;
  final String additionalInfo;

  Item({
    required this.id,
    required this.name,
    required this.menuId,
    required this.type,
    required this.userId,
    required this.availability,
    required this.additionalInfo,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      menuId: json['menuId'],
      type: json['type'],
      userId: json['userId'],
      availability: json['availability'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'menuId': menuId,
      'type': type,
      'userId': userId,
      'availability': availability,
      'additionalInfo': additionalInfo,
    };
  }
}
