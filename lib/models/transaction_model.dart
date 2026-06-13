import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.timestamp,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc){
    final data=doc.data() as Map<String,dynamic>;
    return TransactionModel(id: 
    doc.id,
     title: data['title']??'', 
     amount: (data['amount'] as num).toDouble(),
     type: data['type']??'',
     category: data['category']??'',
     timestamp: (data['timestamp'] as Timestamp).toDate());
  }

  Map<String,dynamic> toMap(){
    return{
      'title':title,
      'amount':amount,
      'type':type,
      'category':category,
      'timestampe':Timestamp.fromDate(timestamp),
    };
  }
}