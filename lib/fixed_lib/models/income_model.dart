import 'package:hive/hive.dart';

part 'income_model.g.dart';

@HiveType(typeId: 2)
class IncomeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String source;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String description;

  @HiveField(5)
  String userId; // ✅ user-specific field

  IncomeModel({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.description,
    required this.userId,
  });
}
