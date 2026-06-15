import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String paymentMethod;

  @HiveField(5)
  String description;

  @HiveField(6)
  String userId; // ✅ user-specific field

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.description,
    required this.userId,
  });
}
