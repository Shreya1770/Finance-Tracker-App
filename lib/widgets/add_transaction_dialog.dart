import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTransactionDialog extends ConsumerStatefulWidget{
  const AddTransactionDialog({super.key});
  @override
  ConsumerState<AddTransactionDialog> createState()=>_AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog>{
  final  _titleController=TextEditingController();
  final _amountController=TextEditingController();

   String _selectedCategory="Food";
  String _selectedType="Expense";
  DateTime _selectedDate=DateTime.now();

  final List<String> _categories=[
    "Food",
    "Travel",
    "Cosmetics",
    "Bills",
    "Salary",
    "Shopping",
    "Entertainment",
    "Health",
    "HouseRent",
    "Others"
  ];

  @override
  Widget build(BuildContext context) {
   return AlertDialog(
    title: const Text("Add Transaction"),
    content: const Text("Dialog Ui will come next"),
   );
  }

}