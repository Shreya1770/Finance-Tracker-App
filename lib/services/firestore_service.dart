import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/transaction_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> addTransaction(String uid,TransactionModel transaction)
  async{
    await _firestore.collection('users')
    .doc(uid)
    .collection('transactions')
    .add(transaction.toMap());
  }

  Stream<List<TransactionModel>> getTransactions(String uid){
    return _firestore.collection('users')
    .doc(uid)
    .collection('transactions')
    .orderBy('timestamp',descending: true)
    .snapshots()
    .map((snapshot){
      return snapshot.docs
      .map((doc)=>TransactionModel.fromFirestore(doc))
      .toList();
    });    
    
  }

  Future<void> updateTransaction(String uid,String transactionId,TransactionModel transaction)
  async{
    await _firestore.collection('users')
    .doc(uid)
    .collection('transactions')
    .doc(transaction.id)
    .update(transaction.toMap());
  }

   Future<void> deleteTransaction(String uid,String transactionId)
  async{
    await _firestore.collection('users')
    .doc(uid)
    .collection('transactions')
    .doc(transactionId)
    .delete();
  }

  Future<String?> getFirstName(String uid) async {
  final doc = await _firestore
      .collection('users')
      .doc(uid)
      .get();

  if (doc.exists) {
    return doc.data()?['firstname'] as String?;
  }

  return null;
}



}