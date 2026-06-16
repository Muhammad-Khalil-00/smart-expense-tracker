import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final monthlyBudget = budgetProvider.getMonthlyBudget(now.month, now.year);
    final monthlySpent = expenseProvider.totalForMonth(now.month, now.year);

    return Scaffold(
      appBar: AppBar(title: Text('Budget • ${AppHelpers.formatMonthYear(now)}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _budgetCard(
            context: context,
            title: 'Overall Monthly Budget',
            budget: monthlyBudget,
            spent: monthlySpent,
            onEdit: () => _editBudget(context, null, monthlyBudget),
          ),
          const SizedBox(height: 20),
          const Text('Category Budgets',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...AppConstants.expenseCategories.map((category) {
            final budget = budgetProvider.getCategoryBudget(category, now.month, now.year);
            final spent = expenseProvider.totalForCategoryInMonth(category, now.month, now.year);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _budgetCard(
                context: context,
                title: category,
                budget: budget,
                spent: spent,
                onEdit: () => _editBudget(context, category, budget),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _budgetCard({
    required BuildContext context,
    required String title,
    required double? budget,
    required double spent,
    required VoidCallback onEdit,
  }) {
    final hasBudget = budget != null && budget > 0;
    final progress = hasBudget ? (spent / budget!).clamp(0.0, 1.0) : 0.0;
    final isOver = hasBudget && spent > budget!;

    Color progressColor;
    if (!hasBudget) {
      progressColor = Colors.white24;
    } else if (isOver) {
      progressColor = AppColors.expense;
    } else if (progress > 0.8) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.income;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hasBudget ? progress : 0,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: progressColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${AppHelpers.formatCurrency(spent)}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              Text(
                hasBudget ? 'Budget: ${AppHelpers.formatCurrency(budget!)}' : 'No budget set',
                style: TextStyle(color: isOver ? AppColors.expense : Colors.white60, fontSize: 12),
              ),
            ],
          ),
          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Over budget by ${AppHelpers.formatCurrency(spent - budget!)}',
                style: const TextStyle(color: AppColors.expense, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  void _editBudget(BuildContext context, String? category, double? currentBudget) {
    final controller = TextEditingController(text: currentBudget?.toStringAsFixed(0) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          category == null ? 'Set Monthly Budget' : 'Set Budget: $category',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            prefixText: 'Rs. ',
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              final now = DateTime.now();
              final budgetProvider = context.read<BudgetProvider>();
              if (category == null) {
                await budgetProvider.setMonthlyBudget(amount, now.month, now.year);
              } else {
                await budgetProvider.setCategoryBudget(category, amount, now.month, now.year);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
