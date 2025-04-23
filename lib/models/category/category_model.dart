import 'package:uuid/uuid.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final int? color;
  final String? icon;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    String? id,
    required this.name,
    required this.type,
    this.color,
    this.icon,
    this.isDefault = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CategoryModel copyWith({
    String? name,
    String? type,
    int? color,
    String? icon,
    bool? isDefault,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'isDefault': isDefault ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      color: map['color'],
      icon: map['icon'],
      isDefault: map['isDefault'] == 1,
      isArchived: map['isArchived'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
  
  // Get color as a Flutter Color object
  dynamic get colorValue {
    if (color == null) {
      return null;
    }
    return color;
  }
}