class MenuItem {
  final String id;
  final String name;
  final int price; // Unit price (harga satuan)
  final int quantity; // Order count / multiplier (default 1)
  final String emoji;
  final List<String> assignedTo; // List of Friend IDs

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.emoji = '🍜',
    this.assignedTo = const [],
  });

  bool isAssignedTo(String friendId) => assignedTo.contains(friendId);

  int get sharedCount => assignedTo.length;

  bool get isShared => assignedTo.length > 1;

  int get unitPrice => price;

  int get totalPrice => price * quantity;

  double get pricePerPerson => assignedTo.isNotEmpty ? totalPrice / assignedTo.length : 0.0;

  MenuItem copyWith({
    String? id,
    String? name,
    int? price,
    int? quantity,
    String? emoji,
    List<String>? assignedTo,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      emoji: emoji ?? this.emoji,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'emoji': emoji,
    'assignedTo': assignedTo,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    quantity: (json['quantity'] as int?) ?? 1,
    emoji: (json['emoji'] as String?) ?? '🍜',
    assignedTo: List<String>.from((json['assignedTo'] as List<dynamic>?) ?? []),
  );
}
