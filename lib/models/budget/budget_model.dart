import 'package:uuid/uuid.dart';

class BudgetModel {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final String? categoryId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecurring;
  final String? recurringType; // 'monthly', 'quarterly', 'yearly'
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    String? id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    this.categoryId,
    required this.startDate,
    required this.endDate,
    this.isRecurring = false,
    this.recurringType,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  BudgetModel copyWith({
    String? name,
    double? amount,
    double? spent,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecurring,
    String? recurringType,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'categoryId': categoryId,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringType': recurringType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      spent: map['spent'],
      categoryId: map['categoryId'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      isRecurring: map['isRecurring'] == 1,
      recurringType: map['recurringType'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  double get percentSpent => amount > 0 ? (spent / amount) * 100 : 0;
  double get remaining => amount - spent;
  bool get isOverBudget => spent > amount;
}