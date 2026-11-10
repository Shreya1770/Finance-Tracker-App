import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditBudgetDialog extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const EditBudgetDialog({
    super.key,
    required this.budget,
  });

  @override
  ConsumerState<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends ConsumerState<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  late String _selectedCategory;

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
    _limitController = TextEditingController(
      text: widget.budget.limit.toStringAsFixed(
        widget.budget.limit.truncateToDouble() == widget.budget.limit ? 0 : 2,
      ),
    );
    _selectedCategory = widget.budget.category;
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
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

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    final limit = double.parse(_limitController.text.trim());

    final updatedBudget = widget.budget.copyWith(
      category: _selectedCategory,
      limit: limit,
    );

    await ref.read(budgetNotifierProvider.notifier).updateBudget(
          uid,
          widget.budget.id,
          updatedBudget,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(budgetNotifierProvider);

    return AlertDialog(
      backgroundColor: AppColors.dialogBg,
      title: const Text('Edit Budget'),
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
                      _formatMonthDisplay(widget.budget.month),
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
          onPressed: isLoading ? null : _updateBudget,
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
              : const Text('Update'),
        ),
      ],
    );
  }
}

