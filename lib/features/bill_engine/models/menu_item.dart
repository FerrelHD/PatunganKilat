class MenuItem {
  final String id;
  final String name;
  final int price;
  final String emoji;
  final List<String> assignedTo; // List of Friend IDs

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.emoji = '🍜',
    this.assignedTo = const [],
  });

  bool isAssignedTo(String friendId) => assignedTo.contains(friendId);

  int get sharedCount => assignedTo.length;

  bool get isShared => assignedTo.length > 1;

  double get pricePerPerson => assignedTo.isNotEmpty ? price / assignedTo.length : 0.0;

  MenuItem copyWith({
    String? id,
    String? name,
    int? price,
    String? emoji,
    List<String>? assignedTo,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      emoji: emoji ?? this.emoji,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'emoji': emoji,
    'assignedTo': assignedTo,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    emoji: (json['emoji'] as String?) ?? '🍜',
    assignedTo: List<String>.from((json['assignedTo'] as List<dynamic>?) ?? []),
  );
}
