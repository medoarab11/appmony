import 'package:uuid/uuid.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income', 'expense', or 'transfer'
  final String? categoryId;
  final String walletId;
  final String? description;
  final DateTime date;
  final bool isRecurring;
  final String? recurringType; // 'daily', 'weekly', 'monthly', 'yearly'
  final int? recurringInterval;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    String? id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.walletId,
    this.description,
    DateTime? date,
    this.isRecurring = false,
    this.recurringType,
    this.recurringInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TransactionModel copyWith({
    double? amount,
    String? type,
    String? categoryId,
    String? walletId,
    String? description,
    DateTime? date,
    bool? isRecurring,
    String? recurringType,
    int? recurringInterval,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      description: description ?? this.description,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'walletId': walletId,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringType': recurringType,
      'recurringInterval': recurringInterval,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['categoryId'],
      walletId: map['walletId'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isRecurring: map['isRecurring'] == 1,
      recurringType: map['recurringType'],
      recurringInterval: map['recurringInterval'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
  
  // Convenience getters
  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get isTransfer => type == 'transfer';
}