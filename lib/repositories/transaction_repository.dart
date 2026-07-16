import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/firestore_service.dart';

class TransactionRepository {
  final FirestoreService _firestoreService;

  TransactionRepository(this._firestoreService);
    Future<void> addTransaction(String uid,TransactionModel transaction,)async{
      await _firestoreService.addTransaction(uid, transaction);
    }

    Stream<List<TransactionModel>> getTransactions(String uid){
      return _firestoreService.getTransactions(uid);
    }

    Future<void> updateTransactions(String uid,String transactionId,TransactionModel transaction)async{
      await _firestoreService.updateTransaction(uid,transactionId, transaction);
    }

    Future<void> deleteTransactions(String uid,String transactionId)async{
      await _firestoreService.deleteTransaction(uid, transactionId);

    }

 
}