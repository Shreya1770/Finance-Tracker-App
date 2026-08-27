import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionDialog extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionDialog> createState() =>
      _EditTransactionDialogState();
}

class _EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late String _selectedCategory;
  late String _selectedType;
  late DateTime _selectedDate;

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

    // Load existing transaction values
    _titleController = TextEditingController(text: widget.transaction.title);

    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );

    _selectedCategory = widget.transaction.category;

    _selectedType = widget.transaction.type;

    _selectedDate = widget.transaction.timestamp;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Transaction"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITLE
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            // AMOUNT
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY
            DropdownButtonFormField<String>(
              value: _selectedCategory,

              decoration: const InputDecoration(
                labelText: "Category",
                prefixIcon: Icon(Icons.category_outlined),
              ),

              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // TYPE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Type",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Income"),
                    value: "income",
                    groupValue: _selectedType,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Expense"),
                    value: "expense",
                    groupValue: _selectedType,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // DATE
            ListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text("Date"),

              subtitle: Text(
                "${_selectedDate.day}/"
                "${_selectedDate.month}/"
                "${_selectedDate.year}",
              ),

              trailing: const Icon(Icons.calendar_today),

              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: _updateTransaction,
          child: const Text("Save Changes"),
        ),
      ],
    );
  }

  // ==========================================================
  // UPDATE
  // ==========================================================

  Future<void> _updateTransaction() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    final uid = ref.read(authServiceProvider).currentUser!.uid;

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,

      title: _titleController.text.trim(),

      amount: amount,

      category: _selectedCategory,

      type: _selectedType,

      timestamp: _selectedDate,
    );

    await ref
        .read(transactionNotifierProvider.notifier)
        .updateTransactions(uid, widget.transaction.id, updatedTransaction);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }
}
