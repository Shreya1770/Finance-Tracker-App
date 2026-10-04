import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> addBudget(String uid,BudgetModel budget)
    async{
      await _firestore.collection('users')
      .doc(uid)
      .collection('budgets')
      .add(budget.toMap());
    }

    Stream<List<BudgetModel>> getBudgets(String uid) {
  return _firestore
      .collection('users')
      .doc(uid)
      .collection('budgets')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return BudgetModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();
      });
}

Future<void> updateBudget(String uid,String budgetsId,BudgetModel budget)async{
  await _firestore.collection('users')
  .doc(uid)
  .collection('budgets')
  .doc(budgetsId)
  .update(budget.toMap());
}

Future<void> deleteBudget(String uid,String budgetId)async{
  await _firestore.collection('users')
  .doc(uid)
  .collection('budgets')
  .doc(budgetId)
  .delete();
}
  }
