import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/budget_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Box _sessionBox = Hive.box('session');
  bool _dailyReminder = false;

  @override
  void initState() {
    super.initState();
    _dailyReminder = _sessionBox.get('dailyReminderEnabled', defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text(user?.email ?? '',
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ),
          const SizedBox(height: 24),
          _statRow('Total Income', AppHelpers.formatCurrency(incomeProvider.totalIncome), AppColors.income),
          const SizedBox(height: 8),
          _statRow('Total Expenses', AppHelpers.formatCurrency(expenseProvider.totalExpenses), AppColors.expense),
          const SizedBox(height: 8),
          _statRow(
            'Net Savings',
            AppHelpers.formatCurrency(incomeProvider.totalIncome - expenseProvider.totalExpenses),
            AppColors.primary,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: SwitchListTile(
              value: _dailyReminder,
              onChanged: (val) async {
                setState(() => _dailyReminder = val);
                await _sessionBox.put('dailyReminderEnabled', val);
                if (val) {
                  await NotificationService.instance.scheduleDailyReminder();
                } else {
                  await NotificationService.instance.cancelDailyReminder();
                }
              },
              title: const Text('Daily Expense Reminder', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Get a reminder every evening to log expenses',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout(
                  expenseProvider: context.read<ExpenseProvider>(),
                  incomeProvider: context.read<IncomeProvider>(),
                  budgetProvider: context.read<BudgetProvider>(),
                );
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
