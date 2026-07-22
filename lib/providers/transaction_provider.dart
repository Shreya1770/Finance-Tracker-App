import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/repositories/transaction_repository.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';


class TransactionNotifier extends StateNotifier<bool>{
  final TransactionRepository _repository;
  TransactionNotifier(this._repository):super(false);

  Future<void> addTransaction(String uid,TransactionModel transaction)async{
    state=true;
    try{
      await _repository.addTransaction(uid, transaction);      
    }
    finally{
      state=false;
    }
  }

  // Future<void> getTransaction(String uid) async{
  //   state=true;
  //   try{
  //   await _repository.getTransactions(uid);
  // }
  // finally{
  //   state=false;
  // }
  // }
   Future<void> deleteTransactions(String uid,String transactionId) async{
    state=true;
    try{
    await _repository.deleteTransactions(uid,transactionId);
  }
  finally{
    state=false;
  }
  }

   Future<void> updateTransactions(String uid,String transactionId,TransactionModel transaction) async{
    state=true;
    try{
    await _repository.updateTransactions( uid,transactionId, transaction);
  }
  finally{
    state=false;
  }
  }
  
}

 final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  final firestore = ref.read(firestoreServiceProvider);

  return TransactionRepository(firestore);
});


  final transactionNotifierProvider=StateNotifierProvider<TransactionNotifier,bool>((ref){
final repository=ref.read(transactionRepositoryProvider);
return TransactionNotifier(repository);
  });

  final transactionStreamProvider =
    StreamProvider.family<List<TransactionModel>, String>((ref, uid) {
  return ref
      .read(transactionRepositoryProvider)
      .getTransactions(uid);
});