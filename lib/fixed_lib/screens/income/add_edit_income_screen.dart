import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/income_model.dart';
import '../../providers/income_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';

class AddEditIncomeScreen extends StatefulWidget {
  final IncomeModel? income;
  const AddEditIncomeScreen({super.key, this.income});

  @override
  State<AddEditIncomeScreen> createState() => _AddEditIncomeScreenState();
}

class _AddEditIncomeScreenState extends State<AddEditIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _source = AppConstants.incomeSources.first;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      final i = widget.income!;
      _amountController.text = i.amount.toString();
      _descController.text = i.description;
      _source = i.source;
      _date = i.date;
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
    final incomeProvider = context.read<IncomeProvider>();

    if (_isEditing) {
      await incomeProvider.updateIncome(
        widget.income!,
        amount: amount,
        source: _source,
        date: _date,
        description: _descController.text.trim(),
      );
    } else {
      await incomeProvider.addIncome(
        amount: amount,
        source: _source,
        date: _date,
        description: _descController.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await context.read<IncomeProvider>().deleteIncome(widget.income!);
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
        title: Text(_isEditing ? 'Edit Income' : 'Add Income'),
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
            DropdownButtonFormField<String>(
              value: _source,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Source',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: AppConstants.incomeSources
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => _source = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
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
            ),
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
              child: Text(_isEditing ? 'Update Income' : 'Save Income'),
            ),
          ],
        ),
      ),
    );
  }
}
