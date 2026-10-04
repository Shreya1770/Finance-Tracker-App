import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/repositories/budget_repository.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final budgetServiceProvider=Provider<BudgetService>((ref){
  return BudgetService();
});

final budgetRepositoryProvider=Provider<BudgetRepository>((ref){
  final service=ref.read(budgetServiceProvider);

  return BudgetRepository(service);
});

class BudgetNotifier extends StateNotifier<bool>{
  final BudgetRepository _repository;
  BudgetNotifier(this._repository):super(false);

  Future<void> addBudget(
    String uid,
    BudgetModel budget,
  )async{
    state=true;
    try{
      await _repository.addBudget(uid, budget);
    }
    finally{
      state=false;
    }
  }

  Future<void> deleteBudget(String uid,String budgetId)async{
    state=true;
    try{
      await _repository.deleteBudget(uid, budgetId);
    }
    finally{
      state=false;
    }
  }

  Future<void> updateBudget(String uid,String budgetId,BudgetModel budget)async{
    state=true;
    try{
     await _repository.updateBudget(uid, budgetId, budget);
    }
    finally{
      state=false;
    }
  }
}

  final budgetNotifierProvider=StateNotifierProvider<BudgetNotifier,bool>((ref){
    final repository=ref.read(budgetRepositoryProvider);
    return BudgetNotifier(repository);
  });

  final budgetStreamProvider =
    StreamProvider.family<List<BudgetModel>, String>((ref, uid) {
  final repository = ref.read(budgetRepositoryProvider);

  return repository.getBudgets(uid);
});