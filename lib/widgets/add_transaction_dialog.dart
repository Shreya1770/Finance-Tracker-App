import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/receipt_scanner_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});
  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = "Food";
  String _selectedType = "expense";
  DateTime _selectedDate = DateTime.now();
  bool _isScanning = false;

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
  Widget build(BuildContext context) {
    final isLoading = ref.watch(transactionNotifierProvider);
    return AlertDialog(
      // backgroundColor:AppColors.dialogBg ,
      title: const Text("Add Transaction"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Receipt OCR Scan Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: _isScanning ? null : _showScanOptions,
                icon: _isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.document_scanner_rounded, size: 20),
                label: Text(
                  _isScanning ? "Scanning Receipt..." : "Scan Receipt (Auto-Fill)",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryLight,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                // labelStyle: TextStyle(
                //   color: AppColors.textPrimary,
                // ),                
                hintText: "Enter Title",
                // hintStyle: TextStyle(
                //   color: AppColors.textMuted,
                // ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(
                  // color: AppColors.textPrimary,
                ),
                hintText: "Enter Amount",
                hintStyle: TextStyle(
                  // color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              
              decoration: const InputDecoration(          
                labelText: "Category",
                labelStyle: TextStyle(
                  // color: AppColors.textPrimary,
                ),
                border: OutlineInputBorder(
              ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = "income";
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "income",
                          groupValue: _selectedType,
                          activeColor: AppColors.income,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                        const Text("Income",
                        style: TextStyle(
                          // color: AppColors.textPrimary,
                        ),),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = "expense";
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "expense",
                          groupValue: _selectedType,
                          activeColor: AppColors.expense,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                        const Text("Expense",
                        style: TextStyle(
                          // color: AppColors.textPrimary,
                        ),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Date"),
              subtitle: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
              trailing: const Icon(Icons.calendar_today,
              // color: AppColors.textPrimary,
              ),
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
          onPressed: isLoading ? null : _addTransaction,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Add"),
        ),
      ],
    );
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Scan Receipt",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select a source to automatically extract transaction details",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryLight,
                  ),
                ),
                title: const Text(
                  "Take Photo",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  "Use your camera to snap a receipt",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _scanReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryLight,
                  ),
                ),
                title: const Text(
                  "Choose from Gallery",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  "Select an existing receipt image",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _scanReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanReceipt(ImageSource source) async {
    setState(() => _isScanning = true);
    try {
      final scanner = ref.read(receiptScannerServiceProvider);
      final result = await scanner.scanReceipt(source: source);

      if (!mounted) return;

      if (result != null && result.hasData) {
        setState(() {
          if (result.amount != null) {
            _amountController.text = result.amount!.toStringAsFixed(
              result.amount!.truncateToDouble() == result.amount! ? 0 : 2,
            );
          }
          if (result.merchant != null && result.merchant!.isNotEmpty) {
            _titleController.text = result.merchant!;
          }
          if (result.date != null) {
            _selectedDate = result.date!;
          }
          if (result.suggestedCategory != null &&
              _categories.contains(result.suggestedCategory)) {
            _selectedCategory = result.suggestedCategory!;
          }
          _selectedType = 'expense';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Receipt scanned! Details auto-filled."),
            backgroundColor: AppColors.income,
          ),
        );
      } else if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No text recognized. Please enter details manually."),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Scan error: $e"),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _addTransaction() async {
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

    final transaction = TransactionModel(
      id: "",
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory,
      type: _selectedType,
      timestamp: _selectedDate,
    );
    await ref
        .read(transactionNotifierProvider.notifier)
        .addTransaction(uid, transaction);
    _titleController.clear();
    _amountController.clear();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
