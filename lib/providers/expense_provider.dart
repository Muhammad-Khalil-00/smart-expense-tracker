import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<ExpenseModel> _box = Hive.box<ExpenseModel>('expenses');

  // ✅ Current logged-in user's ID — set this after login
  String _currentUserId = '';

  void setUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearUserId() {
    _currentUserId = '';
    notifyListeners();
  }

  // ✅ Only return expenses belonging to current user
  List<ExpenseModel> get expenses {
    final list = _box.values
        .where((e) => e.userId == _currentUserId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalExpenses =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String description,
  }) async {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      description: description,
      userId: _currentUserId, // ✅ attach to current user
    );
    await _box.add(expense);
    notifyListeners();
  }

  Future<void> updateExpense(
    ExpenseModel expense, {
    required double amount,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String description,
  }) async {
    expense.amount = amount;
    expense.category = category;
    expense.date = date;
    expense.paymentMethod = paymentMethod;
    expense.description = description;
    await expense.save();
    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    await expense.delete();
    notifyListeners();
  }

  double totalForMonth(int month, int year) {
    return expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double totalForCategoryInMonth(String category, int month, int year) {
    return expenses
        .where((e) =>
            e.category == category &&
            e.date.month == month &&
            e.date.year == year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> categoryTotalsForMonth(int month, int year) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      if (e.date.month == month && e.date.year == year) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  List<MapEntry<DateTime, double>> monthlyTrend({int months = 6}) {
    final now = DateTime.now();
    final List<MapEntry<DateTime, double>> result = [];
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final total = totalForMonth(date.month, date.year);
      result.add(MapEntry(date, total));
    }
    return result;
  }
}
