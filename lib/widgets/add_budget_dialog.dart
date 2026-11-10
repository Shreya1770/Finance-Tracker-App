import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  const AddBudgetDialog({super.key, this.initialMonth});

  final String? initialMonth;

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  String _selectedCategory = 'Food';
  late String _selectedMonth;

  final List<String> _categories = [
    "Food",
    "Travel",
    "Cosmetics",
    "Bills",
    "Salary",
    "Shopping",
    "Entertainment",
    "Health",
    "HouseRent",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = widget.initialMonth ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  String _formatMonthDisplay(String yyyyMm) {
    try {
      final parts = yyyyMm.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return yyyyMm;
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    final limit = double.parse(_limitController.text.trim());

    // Check if a budget already exists for this category & month
    final existingBudgets = ref.read(budgetStreamProvider(uid)).value ?? [];
    final existing = existingBudgets.where(
      (b) => b.category == _selectedCategory && b.month == _selectedMonth,
    ).firstOrNull;

    if (existing != null) {
      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.dialogBg,
          title: const Text('Budget Already Exists'),
          content: Text(
            'A budget for $_selectedCategory for ${_formatMonthDisplay(_selectedMonth)} already exists with limit ₹${existing.limit.toStringAsFixed(0)}.\n\nWould you like to update it to ₹${limit.toStringAsFixed(0)}?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      );

      if (shouldUpdate == true) {
        await ref.read(budgetNotifierProvider.notifier).updateBudget(
              uid,
              existing.id,
              existing.copyWith(limit: limit),
            );
        if (mounted) {
          Navigator.pop(context);
        }
      }
      return;
    }

    final budget = BudgetModel(
      id: '',
      category: _selectedCategory,
      limit: limit,
      month: _selectedMonth,
    );

    await ref
        .read(budgetNotifierProvider.notifier)
        .addBudget(uid, budget);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(budgetNotifierProvider);

    return AlertDialog(
      backgroundColor: AppColors.dialogBg,
      title: const Text('Add Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Indicator Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatMonthDisplay(_selectedMonth),
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                dropdownColor: AppColors.cardBg,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a budget limit';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
