import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction_filter.dart';
import 'package:expense_tracker/models/transaction_model.dart';

void main() {
  group('TransactionFilter Unit Tests', () {
    final sampleTransactions = [
      TransactionModel(
        id: '1',
        title: 'Grocery shopping',
        amount: 2500.0,
        type: 'expense',
        category: 'Food',
        timestamp: DateTime(2026, 11, 1, 10, 0),
      ),
      TransactionModel(
        id: '2',
        title: 'Uber to office',
        amount: 450.0,
        type: 'expense',
        category: 'Travel',
        timestamp: DateTime(2026, 11, 3, 9, 30),
      ),
      TransactionModel(
        id: '3',
        title: 'Monthly Salary',
        amount: 85000.0,
        type: 'income',
        category: 'Salary',
        timestamp: DateTime(2026, 11, 5, 12, 0),
      ),
      TransactionModel(
        id: '4',
        title: 'Electricity Bill',
        amount: 1800.0,
        type: 'expense',
        category: 'Bills',
        timestamp: DateTime(2026, 11, 8, 14, 0),
      ),
      TransactionModel(
        id: '5',
        title: 'Dinner with friends',
        amount: 1200.0,
        type: 'expense',
        category: 'Food',
        timestamp: DateTime(2026, 11, 10, 20, 0),
      ),
      TransactionModel(
        id: '6',
        title: 'Freelance Design',
        amount: 15000.0,
        type: 'income',
        category: 'Others',
        timestamp: DateTime(2026, 11, 11, 16, 0),
      ),
    ];

    test('Default filter returns all transactions', () {
      const filter = TransactionFilter();
      expect(filter.hasActiveFilters, isFalse);
      expect(filter.activeFilterCount, 0);

      final results = filter.apply(sampleTransactions);
      expect(results.length, sampleTransactions.length);
    });

    test('Search by title (case-insensitive & partial match)', () {
      const filter = TransactionFilter(searchQuery: 'dinner');
      final results = filter.apply(sampleTransactions);

      expect(results.length, 1);
      expect(results.first.title, 'Dinner with friends');

      const filter2 = TransactionFilter(searchQuery: 'ER'); // Uber, Dinner, Grocery (titles) and Others (category)
      final results2 = filter2.apply(sampleTransactions);
      expect(results2.length, 4);
    });

    test('Search by category name via search query', () {
      const filter = TransactionFilter(searchQuery: 'travel');
      final results = filter.apply(sampleTransactions);

      expect(results.length, 1);
      expect(results.first.category, 'Travel');
    });

    test('Filter by transaction type (income / expense)', () {
      const expenseFilter = TransactionFilter(type: 'expense');
      final expenses = expenseFilter.apply(sampleTransactions);
      expect(expenses.length, 4);
      expect(expenses.every((t) => t.type == 'expense'), isTrue);

      const incomeFilter = TransactionFilter(type: 'income');
      final incomes = incomeFilter.apply(sampleTransactions);
      expect(incomes.length, 2);
      expect(incomes.every((t) => t.type == 'income'), isTrue);
    });

    test('Filter by category', () {
      const foodFilter = TransactionFilter(category: 'Food');
      final foodTx = foodFilter.apply(sampleTransactions);

      expect(foodTx.length, 2);
      expect(foodTx.every((t) => t.category == 'Food'), isTrue);
    });

    test('Filter by date range', () {
      final filter = TransactionFilter(
        startDate: DateTime(2026, 11, 3),
        endDate: DateTime(2026, 11, 8),
      );
      final results = filter.apply(sampleTransactions);

      // Should include tx 2 (Nov 3), tx 3 (Nov 5), tx 4 (Nov 8)
      expect(results.length, 3);
      expect(results.map((t) => t.id).toList(), containsAll(['2', '3', '4']));
    });

    test('Filter by amount range (min & max amount)', () {
      const filter = TransactionFilter(minAmount: 1000.0, maxAmount: 5000.0);
      final results = filter.apply(sampleTransactions);

      // Grocery (2500), Electricity (1800), Dinner (1200)
      expect(results.length, 3);
      expect(results.every((t) => t.amount >= 1000 && t.amount <= 5000), isTrue);
    });

    test('Multiple composite filters working together', () {
      final filter = TransactionFilter(
        type: 'expense',
        category: 'Food',
        minAmount: 1000.0,
        maxAmount: 2000.0,
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 10),
      );

      final results = filter.apply(sampleTransactions);

      // Only Dinner (Food, expense, 1200, Nov 10) matches both amount and category limits
      expect(results.length, 1);
      expect(results.first.title, 'Dinner with friends');
    });

    test('Active filters count and clear individual filter fields', () {
      final filter = TransactionFilter(
        searchQuery: 'Uber',
        type: 'expense',
        category: 'Travel',
        minAmount: 100.0,
        maxAmount: 1000.0,
      );

      expect(filter.hasActiveFilters, isTrue);
      expect(filter.activeFilterCount, 4); // search, type, category, amount

      final clearedCat = filter.copyWith(clearCategory: true);
      expect(clearedCat.category, isNull);
      expect(clearedCat.activeFilterCount, 3);

      final reset = filter.clear();
      expect(reset.hasActiveFilters, isFalse);
      expect(reset.activeFilterCount, 0);
    });

    test('Sort transactions by date (newest and oldest)', () {
      const newestFilter = TransactionFilter(sortBy: 'newest');
      final newestResults = newestFilter.apply(sampleTransactions);
      expect(newestResults.first.id, '6'); // Nov 11
      expect(newestResults.last.id, '1'); // Nov 1

      const oldestFilter = TransactionFilter(sortBy: 'oldest');
      final oldestResults = oldestFilter.apply(sampleTransactions);
      expect(oldestResults.first.id, '1'); // Nov 1
      expect(oldestResults.last.id, '6'); // Nov 11
    });

    test('Sort transactions by amount (highest and lowest)', () {
      const highestFilter = TransactionFilter(sortBy: 'highest');
      final highestResults = highestFilter.apply(sampleTransactions);
      expect(highestResults.first.amount, 85000.0); // Monthly Salary
      expect(highestResults.last.amount, 450.0); // Uber

      const lowestFilter = TransactionFilter(sortBy: 'lowest');
      final lowestResults = lowestFilter.apply(sampleTransactions);
      expect(lowestResults.first.amount, 450.0); // Uber
      expect(lowestResults.last.amount, 85000.0); // Monthly Salary
    });
  });
}
