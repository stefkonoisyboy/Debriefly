class ActionItem {
  final String description;
  final String owner;
  final String dueDate;

  const ActionItem({
    required this.description,
    required this.owner,
    required this.dueDate,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      description: json['description'] as String,
      owner: json['owner'] as String,
      dueDate: json['dueDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'owner': owner, 'dueDate': dueDate};
  }

  ActionItem copyWith({String? description, String? owner, String? dueDate}) {
    return ActionItem(
      description: description ?? this.description,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          owner == other.owner &&
          dueDate == other.dueDate;

  @override
  int get hashCode => Object.hash(description, owner, dueDate);

  @override
  String toString() =>
      'ActionItem(description: $description, owner: $owner, dueDate: $dueDate)';
}
