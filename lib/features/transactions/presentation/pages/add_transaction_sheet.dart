import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.debit;
  String? _categoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit(List<Category> categories) {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    if (_noteController.text.trim().isEmpty) return;
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }
    if (_categoryId == null) return;

    context.read<TransactionBloc>().add(
          TransactionAddRequested(
            amount: amount,
            note: _noteController.text.trim(),
            type: _type,
            categoryId: _categoryId!,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, catState) {
        final categories = catState.categories;
        if (_categoryId == null && categories.isNotEmpty) {
          _categoryId = categories.first.id;
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: 'Expense',
                      selected: _type == TransactionType.debit,
                      color: AppTheme.danger,
                      onTap: () =>
                          setState(() => _type = TransactionType.debit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeChip(
                      label: 'Income',
                      selected: _type == TransactionType.credit,
                      color: AppTheme.success,
                      onTap: () =>
                          setState(() => _type = TransactionType.credit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Amount (₹)',
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Note (e.g. Grocery Store)',
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              if (categories.isEmpty)
                const Text(
                  'Add a category in Profile first',
                  style: TextStyle(color: AppTheme.danger),
                )
              else
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  dropdownColor: AppTheme.surface,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surface,
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: categories.isEmpty
                    ? null
                    : () => _submit(categories),
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppTheme.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
