import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _category = AppConstants.expenseCategories.first;
  String _paymentMethod = AppConstants.paymentMethods.first;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final e = widget.expense!;
      _amountController.text = e.amount.toString();
      _descController.text = e.description;
      _category = e.category;
      _paymentMethod = e.paymentMethod;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final expenseProvider = context.read<ExpenseProvider>();

    if (_isEditing) {
      await expenseProvider.updateExpense(
        widget.expense!,
        amount: amount,
        category: _category,
        date: _date,
        paymentMethod: _paymentMethod,
        description: _descController.text.trim(),
      );
    } else {
      await expenseProvider.addExpense(
        amount: amount,
        category: _category,
        date: _date,
        paymentMethod: _paymentMethod,
        description: _descController.text.trim(),
      );
    }

    await _checkBudgetAlert();

    if (mounted) Navigator.pop(context);
  }

  /// Generates a Budget Limit Alert notification if spending exceeds
  /// the category or overall monthly budget.
  Future<void> _checkBudgetAlert() async {
    final budgetProvider = context.read<BudgetProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    final categoryBudget =
        budgetProvider.getCategoryBudget(_category, _date.month, _date.year);
    final categorySpent = expenseProvider
        .totalForCategoryInMonth(_category, _date.month, _date.year);

    if (categoryBudget != null && categorySpent > categoryBudget) {
      await NotificationService.instance.showBudgetAlert(
        'Budget Alert: $_category',
        'You have exceeded your $_category budget of '
            '${AppHelpers.formatCurrency(categoryBudget)}.',
      );
      return;
    }

    final monthlyBudget =
        budgetProvider.getMonthlyBudget(_date.month, _date.year);
    final monthlySpent =
        expenseProvider.totalForMonth(_date.month, _date.year);

    if (monthlyBudget != null && monthlySpent > monthlyBudget) {
      await NotificationService.instance.showBudgetAlert(
        'Monthly Budget Exceeded',
        'You have exceeded your monthly budget of '
            '${AppHelpers.formatCurrency(monthlyBudget)}.',
      );
    }
  }

  Future<void> _delete() async {
    await context.read<ExpenseProvider>().deleteExpense(widget.expense!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (_isEditing)
            IconButton(
                icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _amountController,
              label: 'Amount',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _dropdown('Category', _category, AppConstants.expenseCategories,
                (v) => setState(() => _category = v!)),
            const SizedBox(height: 16),
            _dateField(),
            const SizedBox(height: 16),
            _dropdown('Payment Method', _paymentMethod,
                AppConstants.paymentMethods, (v) => setState(() => _paymentMethod = v!)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descController,
              label: 'Description (optional)',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white60),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        child: Text(AppHelpers.formatDate(_date), style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
