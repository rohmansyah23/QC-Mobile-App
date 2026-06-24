import 'app_user.dart';
import 'category_model.dart'; 

class TransactionModel {
  final String id;
  final String type; 
  final DateTime date;
  final int amount;
  final String? description;
  final DateTime createdAt;

  final AppUser? contributor; 
  final CategoryModel? category; 

  TransactionModel({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    this.description,
    required this.createdAt,
    this.contributor,
    this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['transaction_type'],
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toInt(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),

      contributor: json['users'] != null ? AppUser.fromJson(json['users']) : null,
      category: json['categories'] != null ? CategoryModel.fromJson(json['categories']) : null,
    );
  }
}