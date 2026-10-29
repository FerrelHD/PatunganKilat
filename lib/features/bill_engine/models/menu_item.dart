class MenuItem {
  final String id;
  final String name;
  final int price; // Unit price (harga satuan)
  final int quantity; // Order count / multiplier (default 1)
  final String emoji;
  final List<String> assignedTo; // List of Friend IDs
  final Map<String, int> portions; // Map of friendId -> portion count

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.emoji = '🍜',
    this.assignedTo = const [],
    this.portions = const {},
  });

  bool isAssignedTo(String friendId) => assignedTo.contains(friendId);

  int get sharedCount => assignedTo.length;

  bool get isShared => assignedTo.length > 1;

  int get unitPrice => price;

  int get totalPrice => price * quantity;

  /// Returns the allocated portion count for [friendId].
  /// Defaults to 1 if the friend is assigned, or 0 if unassigned.
  int getPortionFor(String friendId) {
    if (!assignedTo.contains(friendId)) return 0;
    return portions[friendId] ?? 1;
  }

  /// Sum of all portions allocated to currently assigned friends.
  int get totalPortions {
    if (assignedTo.isEmpty) return 0;
    return assignedTo.fold<int>(0, (sum, fId) => sum + (portions[fId] ?? 1));
  }

  /// Average price per single portion unit
  double get pricePerPerson => totalPortions > 0 ? totalPrice / totalPortions : 0.0;

  MenuItem copyWith({
    String? id,
    String? name,
    int? price,
    int? quantity,
    String? emoji,
    List<String>? assignedTo,
    Map<String, int>? portions,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      emoji: emoji ?? this.emoji,
      assignedTo: assignedTo ?? this.assignedTo,
      portions: portions ?? this.portions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'emoji': emoji,
    'assignedTo': assignedTo,
    'portions': portions,
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    quantity: (json['quantity'] as int?) ?? 1,
    emoji: (json['emoji'] as String?) ?? '🍜',
    assignedTo: List<String>.from((json['assignedTo'] as List<dynamic>?) ?? []),
    portions: (json['portions'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
  );
}
