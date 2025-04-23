import 'package:uuid/uuid.dart';

class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String currencyCode;
  final int? color;
  final String? icon;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    String? id,
    required this.name,
    this.balance = 0.0,
    required this.currencyCode,
    this.color,
    this.icon,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  WalletModel copyWith({
    String? name,
    double? balance,
    String? currencyCode,
    int? color,
    String? icon,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currencyCode: currencyCode ?? this.currencyCode,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currencyCode': currencyCode,
      'color': color,
      'icon': icon,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      currencyCode: map['currencyCode'],
      color: map['color'],
      icon: map['icon'],
      isArchived: map['isArchived'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}