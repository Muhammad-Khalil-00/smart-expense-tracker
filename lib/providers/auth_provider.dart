import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'budget_provider.dart';

class AuthProvider extends ChangeNotifier {
  final Box<UserModel> _userBox = Hive.box<UserModel>('users');
  final Box _sessionBox = Hive.box('session');

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  /// ✅ Call this on app start to restore session
  Future<bool> tryAutoLogin({
    required ExpenseProvider expenseProvider,
    required IncomeProvider incomeProvider,
    required BudgetProvider budgetProvider,
  }) async {
    final userId = _sessionBox.get('userId');
    if (userId == null) return false;

    try {
      final user = _userBox.values.firstWhere((u) => u.id == userId);
      _currentUser = user;
      // ✅ Restore userId in all providers
      expenseProvider.setUserId(user.id);
      incomeProvider.setUserId(user.id);
      budgetProvider.setUserId(user.id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> register(
    String name,
    String email,
    String password, {
    required ExpenseProvider expenseProvider,
    required IncomeProvider incomeProvider,
    required BudgetProvider budgetProvider,
  }) async {
    final emailLower = email.trim().toLowerCase();
    final exists =
        _userBox.values.any((u) => u.email.toLowerCase() == emailLower);
    if (exists) return 'An account with this email already exists.';

    final salt = _generateSalt();
    final user = UserModel(
      id: const Uuid().v4(),
      name: name.trim(),
      email: emailLower,
      passwordHash: _hashPassword(password, salt),
      createdAt: DateTime.now(),
      salt: salt,
    );

    await _userBox.add(user);
    _currentUser = user;
    await _sessionBox.put('userId', user.id);

    // ✅ Set userId in all providers
    expenseProvider.setUserId(user.id);
    incomeProvider.setUserId(user.id);
    budgetProvider.setUserId(user.id);

    notifyListeners();
    return null;
  }

  Future<String?> login(
    String email,
    String password, {
    required ExpenseProvider expenseProvider,
    required IncomeProvider incomeProvider,
    required BudgetProvider budgetProvider,
  }) async {
    final emailLower = email.trim().toLowerCase();

    UserModel? user;
    try {
      user =
          _userBox.values.firstWhere((u) => u.email.toLowerCase() == emailLower);
    } catch (_) {
      return 'Invalid email or password.';
    }

    final hashed = _hashPassword(password, user.salt);
    if (hashed != user.passwordHash) {
      return 'Invalid email or password.';
    }

    _currentUser = user;
    await _sessionBox.put('userId', user.id);

    // ✅ Set userId in all providers — this is the KEY fix
    expenseProvider.setUserId(user.id);
    incomeProvider.setUserId(user.id);
    budgetProvider.setUserId(user.id);

    notifyListeners();
    return null;
  }

  Future<void> logout({
    required ExpenseProvider expenseProvider,
    required IncomeProvider incomeProvider,
    required BudgetProvider budgetProvider,
  }) async {
    _currentUser = null;
    await _sessionBox.delete('userId');

    // ✅ Clear userId from all providers on logout
    expenseProvider.clearUserId();
    incomeProvider.clearUserId();
    budgetProvider.clearUserId();

    notifyListeners();
  }
}
