import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/features/expenses/domain/entities/expense.dart';
import 'package:livestock/features/expenses/domain/entities/expense_category.dart';

/// Expense data model with JSON serialization
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.cooperativeId,
    required super.description,
    required super.amount,
    required super.category,
    required super.date,
    required super.createdAt,
  });

  /// Create model from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      cooperativeId: json['cooperativeId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(json['category'] as String),
      date: (json['date'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'description': description,
      'amount': amount,
      'category': category.name,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from entity
  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      cooperativeId: entity.cooperativeId,
      description: entity.description,
      amount: entity.amount,
      category: entity.category,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }

  /// Convert model to entity
  Expense toEntity() {
    return Expense(
      id: id,
      cooperativeId: cooperativeId,
      description: description,
      amount: amount,
      category: category,
      date: date,
      createdAt: createdAt,
    );
  }
}
