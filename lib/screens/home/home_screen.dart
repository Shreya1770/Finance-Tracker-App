import 'package:expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid=ref.read(authServiceProvider).currentUser!.uid;
    final transactionsAsync=ref.watch(transactionStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text("PocketPal"),
      ),

      body:transactionsAsync.when(
        data:(transactions){
          return const Center(
            child: Text("Transaction Loaded"),
          );
        }, error: (error,StackTrace){
          return Center(
            child: Text("Error:$error"),
          );
        }, 
        loading: (){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),

      floatingActionButton:  FloatingActionButton(onPressed: (){
      showDialog(context: context, builder:(_)=> const AddTransactionDialog());
      
    },
    child:Icon(Icons.add) ,),
    
      );
    
  }
}