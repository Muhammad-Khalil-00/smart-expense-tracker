import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/income_model.dart';

class IncomeProvider extends ChangeNotifier {
  final Box<IncomeModel> _box = Hive.box<IncomeModel>('income');

  // ✅ Current logged-in user's ID
  String _currentUserId = '';

  void setUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearUserId() {
    _currentUserId = '';
    notifyListeners();
  }

  // ✅ Only return income belonging to current user
  List<IncomeModel> get incomes {
    final list = _box.values
        .where((i) => i.userId == _currentUserId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalIncome => incomes.fold(0.0, (sum, i) => sum + i.amount);

  Future<void> addIncome({
    required double amount,
    required String source,
    required DateTime date,
    required String description,
  }) async {
    final income = IncomeModel(
      id: const Uuid().v4(),
      amount: amount,
      source: source,
      date: date,
      description: description,
      userId: _currentUserId, // ✅ attach to current user
    );
    await _box.add(income);
    notifyListeners();
  }

  Future<void> updateIncome(
    IncomeModel income, {
    required double amount,
    required String source,
    required DateTime date,
    required String description,
  }) async {
    income.amount = amount;
    income.source = source;
    income.date = date;
    income.description = description;
    await income.save();
    notifyListeners();
  }

  Future<void> deleteIncome(IncomeModel income) async {
    await income.delete();
    notifyListeners();
  }

  double totalForMonth(int month, int year) {
    return incomes
        .where((i) => i.date.month == month && i.date.year == year)
        .fold(0.0, (sum, i) => sum + i.amount);
  }
}
