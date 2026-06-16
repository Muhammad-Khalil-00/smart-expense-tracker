import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    final totalExpense = expenseProvider.totalForMonth(now.month, now.year);
    final totalIncome = incomeProvider.totalForMonth(now.month, now.year);
    final savings = totalIncome - totalExpense;

    final categoryTotals =
        expenseProvider.categoryTotalsForMonth(now.month, now.year);
    final trend = expenseProvider.monthlyTrend();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard • ${AppHelpers.formatMonthYear(now)}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Income (This Month)',
                  amount: AppHelpers.formatCurrency(totalIncome),
                  icon: Icons.arrow_downward,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Expenses (This Month)',
                  amount: AppHelpers.formatCurrency(totalExpense),
                  icon: Icons.arrow_upward,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SummaryCard(
            title: 'Savings (This Month)',
            amount: AppHelpers.formatCurrency(savings),
            icon: Icons.savings_outlined,
            color: savings >= 0 ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(height: 24),
          const Text('Category-wise Spending',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (categoryTotals.isEmpty)
            _emptyBox('No expenses recorded this month')
          else
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: categoryTotals.entries.map((e) {
                          return PieChartSectionData(
                            value: e.value,
                            title: '',
                            color: AppConstants.colorFor(e.key),
                            radius: 60,
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: categoryTotals.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  color: AppConstants.colorFor(e.key)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                AppHelpers.formatCurrency(e.value),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const Text('Monthly Spending Trend',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) {
                          return const SizedBox();
                        }
                        final date = trend[index].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            AppHelpers.monthName(date.month).substring(0, 3),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: trend.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: AppColors.primary,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: Colors.white38)),
    );
  }
}
