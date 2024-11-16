class Menu {
  final String id;
  final String name;
  final List<Item> items;

  Menu({required this.id, required this.name, required this.items});

  factory Menu.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<Item> items = itemsList.map((i) => Item.fromJson(i)).toList();

    return Menu(
      id: json['id'],
      name: json['name'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
