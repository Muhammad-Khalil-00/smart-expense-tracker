import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final Box<BudgetModel> _box = Hive.box<BudgetModel>('budgets');

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

  // ✅ Only return budgets belonging to current user
  List<BudgetModel> get all =>
      _box.values.where((b) => b.userId == _currentUserId).toList();

  BudgetModel? _findBudget(String? category, int month, int year) {
    try {
      return _box.values.firstWhere((b) =>
          b.userId == _currentUserId &&
          b.category == category &&
          b.month == month &&
          b.year == year);
    } catch (_) {
      return null;
    }
  }

  double? getMonthlyBudget(int month, int year) {
    return _findBudget(null, month, year)?.amount;
  }

  double? getCategoryBudget(String category, int month, int year) {
    return _findBudget(category, month, year)?.amount;
  }

  Map<String, double> getAllCategoryBudgets(int month, int year) {
    final Map<String, double> map = {};
    for (final b in _box.values) {
      if (b.userId == _currentUserId &&
          b.category != null &&
          b.month == month &&
          b.year == year) {
        map[b.category!] = b.amount;
      }
    }
    return map;
  }

  Future<void> setMonthlyBudget(double amount, int month, int year) async {
    await _setBudget(null, amount, month, year);
  }

  Future<void> setCategoryBudget(
      String category, double amount, int month, int year) async {
    await _setBudget(category, amount, month, year);
  }

  Future<void> _setBudget(
      String? category, double amount, int month, int year) async {
    final existing = _findBudget(category, month, year);
    if (existing != null) {
      existing.amount = amount;
      await existing.save();
    } else {
      final budget = BudgetModel(
        id: const Uuid().v4(),
        category: category,
        amount: amount,
        month: month,
        year: year,
        userId: _currentUserId, // ✅ attach to current user
      );
      await _box.add(budget);
    }
    notifyListeners();
  }

  Future<void> deleteBudget(BudgetModel budget) async {
    await budget.delete();
    notifyListeners();
  }
}
