import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  /// null = overall monthly budget, otherwise category-specific budget
  @HiveField(1)
  String? category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  int month; // 1-12

  @HiveField(4)
  int year;

  @HiveField(5)
  String userId; // ✅ user-specific field

  BudgetModel({
    required this.id,
    this.category,
    required this.amount,
    required this.month,
    required this.year,
    required this.userId,
  });
}
