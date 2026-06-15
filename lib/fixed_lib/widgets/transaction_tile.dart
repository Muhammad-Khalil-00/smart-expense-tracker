import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TransactionTile extends StatelessWidget {
  final bool isExpense;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.isExpense,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? AppColors.expense : AppColors.income;
    final sign = isExpense ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppConstants.colorFor(title).withOpacity(0.2),
          child: Icon(AppConstants.iconFor(title),
              color: AppConstants.colorFor(title)),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$subtitle • ${AppHelpers.formatDate(date)}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${AppHelpers.formatCurrency(amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.delete_outline,
                    color: Colors.white38, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
