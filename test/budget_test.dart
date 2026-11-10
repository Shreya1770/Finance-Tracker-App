import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/budget_model.dart';

void main() {
  group('BudgetModel Tests', () {
    test('BudgetModel correctly deserializes from Map with int and double limits', () {
      final mapWithInt = {
        'category': 'Food',
        'limit': 5000,
        'month': '2026-11',
      };

      final budgetFromInt = BudgetModel.fromMap('b1', mapWithInt);
      expect(budgetFromInt.id, 'b1');
      expect(budgetFromInt.category, 'Food');
      expect(budgetFromInt.limit, 5000.0);
      expect(budgetFromInt.month, '2026-11');

      final mapWithDouble = {
        'category': 'Travel',
        'limit': 2500.50,
        'month': '2026-11',
      };

      final budgetFromDouble = BudgetModel.fromMap('b2', mapWithDouble);
      expect(budgetFromDouble.limit, 2500.50);

      final mapWithNulls = <String, dynamic>{};
      final budgetFromNulls = BudgetModel.fromMap('b3', mapWithNulls);
      expect(budgetFromNulls.category, '');
      expect(budgetFromNulls.limit, 0.0);
      expect(budgetFromNulls.month, '');
    });

    test('BudgetModel correctly serializes to Map', () {
      final budget = BudgetModel(
        id: 'b1',
        category: 'Bills',
        limit: 1200.0,
        month: '2026-11',
      );

      final map = budget.toMap();
      expect(map['category'], 'Bills');
      expect(map['limit'], 1200.0);
      expect(map['month'], '2026-11');
    });

    test('BudgetModel copyWith updates fields correctly', () {
      final original = BudgetModel(
        id: 'b1',
        category: 'Food',
        limit: 3000.0,
        month: '2026-11',
      );

      final updated = original.copyWith(limit: 4500.0, category: 'Groceries');
      expect(updated.id, 'b1');
      expect(updated.category, 'Groceries');
      expect(updated.limit, 4500.0);
      expect(updated.month, '2026-11');
    });

    test('Budget Alert Thresholds: normal, warning and exceeded status', () {
      final budget = BudgetModel(
        id: 'b1',
        category: 'Food',
        limit: 1000.0,
        month: '2026-11',
      );

      // Normal: < 80% (e.g. 500 spent = 50%)
      expect(budget.getStatus(500.0), BudgetStatus.normal);
      expect(budget.getPercentage(500.0), 50.0);
      expect(budget.getRemaining(500.0), 500.0);

      // Normal boundary: 799 spent = 79.9%
      expect(budget.getStatus(799.0), BudgetStatus.normal);

      // Warning threshold: Exactly 80% (800 spent)
      expect(budget.getStatus(800.0), BudgetStatus.warning);
      expect(budget.getPercentage(800.0), 80.0);
      expect(budget.getRemaining(800.0), 200.0);

      // Warning: 95% (950 spent)
      expect(budget.getStatus(950.0), BudgetStatus.warning);

      // Exceeded threshold: Exactly 100% (1000 spent)
      expect(budget.getStatus(1000.0), BudgetStatus.exceeded);
      expect(budget.getPercentage(1000.0), 100.0);
      expect(budget.getRemaining(1000.0), 0.0);

      // Exceeded: > 100% (1200 spent)
      expect(budget.getStatus(1200.0), BudgetStatus.exceeded);
      expect(budget.getPercentage(1200.0), 120.0);
      expect(budget.getRemaining(1200.0), -200.0);
    });
  });
}

