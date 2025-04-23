import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class WalletModel {
  final String? id;
  final String name;
  final String type;
  final double initialBalance;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final String? description;
  final String? currencyCode;
  final Color? color;
  final String? icon;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0.0,
    this.balance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.description,
    this.currencyCode,
    this.color,
    this.icon,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? initialBalance,
    double? balance,
    double? totalIncome,
    double? totalExpense,
    String? description,
    String? currencyCode,
    Color? color,
    String? icon,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      description: description ?? this.description,
      currencyCode: currencyCode ?? this.currencyCode,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? const Uuid().v4(),
      'name': name,
      'type': type,
      'initialBalance': initialBalance,
      'balance': balance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'description': description,
      'currencyCode': currencyCode,
      'color': color?.value,
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
      type: map['type'] ?? 'cash',
      initialBalance: map['initialBalance']?.toDouble() ?? 0.0,
      balance: map['balance']?.toDouble() ?? 0.0,
      totalIncome: map['totalIncome']?.toDouble() ?? 0.0,
      totalExpense: map['totalExpense']?.toDouble() ?? 0.0,
      description: map['description'],
      currencyCode: map['currencyCode'],
      color: map['color'] != null ? Color(map['color']) : null,
      icon: map['icon'],
      isArchived: map['isArchived'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}