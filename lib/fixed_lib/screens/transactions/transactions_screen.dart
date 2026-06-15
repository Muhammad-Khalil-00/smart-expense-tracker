import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../models/income_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/transaction_tile.dart';
import '../expense/add_edit_expense_screen.dart';
import '../income/add_edit_income_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _typeFilter = 'All'; // All, Expense, Income
  String _categoryFilter = 'All';
  DateTime? _monthFilter; // null = all time

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    final query = _searchController.text.toLowerCase();
    final items = <_TxItem>[];

    if (_typeFilter != 'Income') {
      for (final e in expenseProvider.expenses) {
        items.add(_TxItem.fromExpense(e));
      }
    }
    if (_typeFilter != 'Expense') {
      for (final i in incomeProvider.incomes) {
        items.add(_TxItem.fromIncome(i));
      }
    }

    final filtered = items.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
      final matchesCategory =
          _categoryFilter == 'All' || item.title == _categoryFilter;
      final matchesMonth = _monthFilter == null ||
          (item.date.month == _monthFilter!.month &&
              item.date.year == _monthFilter!.year);
      return matchesSearch && matchesCategory && matchesMonth;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    final allCategories = [
      'All',
      ...AppConstants.expenseCategories,
      ...AppConstants.incomeSources,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(
                    'All', _typeFilter, (v) => setState(() => _typeFilter = v)),
                _filterChip('Expense', _typeFilter,
                    (v) => setState(() => _typeFilter = v)),
                _filterChip('Income', _typeFilter,
                    (v) => setState(() => _typeFilter = v)),
                const SizedBox(width: 8),
                _monthChip(),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: _categoryFilter,
                dropdownColor: AppColors.card,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                items: allCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryFilter = v ?? 'All'),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No transactions found',
                        style: TextStyle(color: Colors.white38)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return TransactionTile(
                        isExpense: item.isExpense,
                        title: item.title,
                        subtitle: item.subtitle,
                        amount: item.amount,
                        date: item.date,
                        onTap: () => _openEdit(item),
                        onDelete: () => _delete(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, String selected, Function(String) onSelect) {
    final isSelected = selected == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelect(label),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.card,
        labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _monthChip() {
    final label = _monthFilter == null
        ? 'All Time'
        : '${AppHelpers.monthName(_monthFilter!.month)} ${_monthFilter!.year}';
    return InputChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.card,
      labelStyle: const TextStyle(color: Colors.white70),
      avatar: const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
      onPressed: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _monthFilter ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
          helpText: 'Select any date in the month to filter',
        );
        // If the user cancels, keep the existing filter unchanged.
        if (picked != null) {
          setState(() => _monthFilter = picked);
        }
      },
      onDeleted: _monthFilter != null
          ? () => setState(() => _monthFilter = null)
          : null,
      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.remove_circle_outline, color: AppColors.expense),
              title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.income),
              title: const Text('Add Income', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEditIncomeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(_TxItem item) {
    if (item.isExpense) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddEditExpenseScreen(expense: item.expense)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddEditIncomeScreen(income: item.income)),
      );
    }
  }

  void _delete(_TxItem item) {
    if (item.isExpense) {
      context.read<ExpenseProvider>().deleteExpense(item.expense!);
    } else {
      context.read<IncomeProvider>().deleteIncome(item.income!);
    }
  }
}

class _TxItem {
  final bool isExpense;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final ExpenseModel? expense;
  final IncomeModel? income;

  _TxItem._({
    required this.isExpense,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.expense,
    this.income,
  });

  factory _TxItem.fromExpense(ExpenseModel e) => _TxItem._(
        isExpense: true,
        title: e.category,
        subtitle: e.description.isEmpty ? e.paymentMethod : e.description,
        amount: e.amount,
        date: e.date,
        expense: e,
      );

  factory _TxItem.fromIncome(IncomeModel i) => _TxItem._(
        isExpense: false,
        title: i.source,
        subtitle: i.description.isEmpty ? 'Income' : i.description,
        amount: i.amount,
        date: i.date,
        income: i,
      );
}
