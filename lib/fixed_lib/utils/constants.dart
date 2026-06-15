import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

class AppConstants {
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  static const List<String> incomeSources = [
    'Salary',
    'Business',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'Bank Transfer',
    'Mobile Wallet',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Education': Icons.school,
    'Salary': Icons.work,
    'Business': Icons.store,
    'Freelance': Icons.laptop_mac,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Other': Icons.category,
  };

  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFF59E0B),
    'Transport': Color(0xFF3B82F6),
    'Shopping': Color(0xFFEC4899),
    'Bills': Color(0xFF8B5CF6),
    'Entertainment': Color(0xFF06B6D4),
    'Health': Color(0xFFEF4444),
    'Education': Color(0xFF10B981),
    'Salary': Color(0xFF22C55E),
    'Business': Color(0xFF14B8A6),
    'Freelance': Color(0xFF6366F1),
    'Investment': Color(0xFFF97316),
    'Gift': Color(0xFFEC4899),
    'Other': Color(0xFF94A3B8),
  };

  static IconData iconFor(String category) =>
      categoryIcons[category] ?? Icons.category;

  static Color colorFor(String category) =>
      categoryColors[category] ?? const Color(0xFF94A3B8);
}
