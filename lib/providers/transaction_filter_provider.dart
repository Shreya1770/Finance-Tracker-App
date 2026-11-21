import 'package:expense_tracker/models/transaction_filter.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return const TransactionFilter();
});

final filteredTransactionsAsyncProvider =
    Provider.family<AsyncValue<List<TransactionModel>>, String>((ref, uid) {
  final transactionsAsync = ref.watch(transactionStreamProvider(uid));
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.whenData(
    (transactions) => filter.apply(transactions),
  );
});
