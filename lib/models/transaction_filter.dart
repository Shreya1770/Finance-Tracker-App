import 'package:expense_tracker/models/transaction_model.dart';

class TransactionFilter {
  final String searchQuery;
  final String type; // 'all', 'income', 'expense'
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String sortBy; // 'newest', 'oldest', 'highest', 'lowest'

  const TransactionFilter({
    this.searchQuery = '',
    this.type = 'all',
    this.category,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.sortBy = 'newest',
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      type != 'all' ||
      (category != null && category!.isNotEmpty && category != 'All') ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      sortBy != 'newest';

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.trim().isNotEmpty) count++;
    if (type != 'all') count++;
    if (category != null && category!.isNotEmpty && category != 'All') count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (sortBy != 'newest') count++;
    return count;
  }

  TransactionFilter copyWith({
    String? searchQuery,
    String? type,
    String? category,
    bool clearCategory = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    String? sortBy,
    bool resetSort = false,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: type ?? this.type,
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      sortBy: resetSort ? 'newest' : (sortBy ?? this.sortBy),
    );
  }

  TransactionFilter clear() => const TransactionFilter();

  List<TransactionModel> apply(List<TransactionModel> transactions) {
    final filtered = transactions.where((tx) {
      // 1. Search Query: Matches title or category (case-insensitive)
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(query);
        final matchCategory = tx.category.toLowerCase().contains(query);
        if (!matchTitle && !matchCategory) {
          return false;
        }
      }

      // 2. Transaction Type: 'all', 'income', or 'expense'
      if (type != 'all') {
        if (tx.type.toLowerCase() != type.toLowerCase()) {
          return false;
        }
      }

      // 3. Category Filter
      if (category != null && category!.isNotEmpty && category != 'All') {
        if (tx.category.toLowerCase().trim() != category!.toLowerCase().trim()) {
          return false;
        }
      }

      // 4. Date Range Filter
      if (startDate != null) {
        final startOfDay = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        if (tx.timestamp.isBefore(startOfDay)) {
          return false;
        }
      }

      if (endDate != null) {
        final endOfDay = DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
          23,
          59,
          59,
          999,
        );
        if (tx.timestamp.isAfter(endOfDay)) {
          return false;
        }
      }

      // 5. Amount Range Filter
      if (minAmount != null && tx.amount < minAmount!) {
        return false;
      }

      if (maxAmount != null && tx.amount > maxAmount!) {
        return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'highest':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'lowest':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }

    return filtered;
  }
}
