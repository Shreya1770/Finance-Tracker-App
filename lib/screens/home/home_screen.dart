import 'package:expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PocketPal"),
      ),

      body: const Center(
        child: Text("No Transactions Yet"),
      ),

      floatingActionButton:  FloatingActionButton(onPressed: (){
      showDialog(context: context, builder:(_)=> const AddTransactionDialog());
      
    },
    child:Icon(Icons.add) ,),
    
      );
    
  }
}