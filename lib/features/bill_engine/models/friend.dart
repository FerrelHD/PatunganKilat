class Friend {
  final String id;
  final String name;
  final String role; // 'Talangan' or 'Teman'
  final String theme; // 'lime', 'dark', 'white'

  const Friend({
    required this.id,
    required this.name,
    this.role = 'Teman',
    this.theme = 'white',
  });

  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  bool get isPayer => role.toLowerCase() == 'talangan';

  Friend copyWith({
    String? id,
    String? name,
    String? role,
    String? theme,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'theme': theme,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] as String,
    name: json['name'] as String,
    role: (json['role'] as String?) ?? 'Teman',
    theme: (json['theme'] as String?) ?? 'white',
  );
}
