import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/services/budget_service.dart';

class BudgetRepository {
  final BudgetService _budgetService;

  BudgetRepository(this._budgetService);
  Future<void> addBudget(String uid,BudgetModel budget)async{
    await _budgetService.addBudget(uid,budget);
  }

  Future<void> updateBudget(String uid,String budgetId,BudgetModel budget)async{
    await _budgetService.updateBudget(
      uid,budgetId,budget
    );
    
  }

  Future<void> deleteBudget(
    String uid,String budgetId
  )async{
    await _budgetService.deleteBudget(uid, budgetId);
  }

  Stream<List<BudgetModel>> getBudgets(
    String uid,
  ){
    return _budgetService.getBudgets(uid);

  }
}