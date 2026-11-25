import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/transaction_filter.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_filter_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/analystics_screen.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:expense_tracker/screens/budget_screen.dart';
import 'package:expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:expense_tracker/widgets/edit_transaction_dialog.dart';
import 'package:expense_tracker/widgets/export_statement_dialog.dart';
import 'package:expense_tracker/widgets/transaction_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(transactionFilterProvider.notifier).state =
        const TransactionFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(context),
          const AnalyticsScreen(),
          const BudgetScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddTransactionDialog(),
                );
              },
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryMuted,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: "Budget",
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final uid = ref.read(authServiceProvider).currentUser!.uid;
    final transactionsAsync = ref.watch(transactionStreamProvider(uid));
    final filter = ref.watch(transactionFilterProvider);
    final firstNameAsync = ref.watch(firstNameProvider);

    return transactionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Text(
          "Something went wrong:\n$error",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.expense),
        ),
      ),
      data: (transactions) {
        double totalIncome = 0;
        double totalExpense = 0;

        for (final transaction in transactions) {
          if (transaction.type == "income") {
            totalIncome += transaction.amount;
          } else if (transaction.type == "expense") {
            totalExpense += transaction.amount;
          }
        }

        final balance = totalIncome - totalExpense;

        // Apply filters in-memory
        final filteredTransactions = filter.apply(transactions);

        // Keep search controller in sync if cleared externally
        if (filter.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
          _searchController.clear();
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Top Gradient Background
                  Container(
                    height: 230,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 20, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: firstNameAsync.when(
                                data: (firstName) {
                                  return Text(
                                    "Hey ${firstName ?? 'there'} 👋",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                                loading: () {
                                  return const Text(
                                    "Hey there 👋",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                                error: (_, __) {
                                  return const Text(
                                    "Hey there 👋",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                              tooltip: "Export Statement",
                              onPressed: () {
                                ExportStatementDialog.show(
                                  context,
                                  transactions: transactions,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                              tooltip: "Log Out",
                              onPressed: () => _confirmLogout(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 145,
                      left: 20,
                      right: 20,
                    ),
                    child: _balanceCard(
                      context,
                      balance,
                      totalIncome,
                      totalExpense,
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 2. Search & Filter Bar
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context, filter),
                    const SizedBox(height: 12),
                    _buildQuickTypeSelector(filter),
                    if (filter.hasActiveFilters) ...[
                      const SizedBox(height: 10),
                      _buildActiveFilterChips(filter),
                    ],
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 3. Transactions Section Header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filter.hasActiveFilters
                          ? "Filtered Transactions"
                          : "Recent Transactions",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "${filteredTransactions.length} of ${transactions.length}",
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 4. Transaction List or Empty States
            if (transactions.isEmpty)
              SliverToBoxAdapter(child: _emptyTransactions(context))
            else if (filteredTransactions.isEmpty)
              SliverToBoxAdapter(child: _emptyFilteredTransactions())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = filteredTransactions[index];
                      final isIncome = transaction.type == "income";

                      return Slidable(
                        key: ValueKey(transaction.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _showEditTransactionDialog(
                                  context,
                                  ref,
                                  transaction,
                                );
                              },
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              icon: Icons.edit_outlined,
                              label: 'Edit',
                              borderRadius: BorderRadius.circular(16),
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                final uid = ref
                                    .read(authServiceProvider)
                                    .currentUser!
                                    .uid;

                                await ref
                                    .read(transactionNotifierProvider.notifier)
                                    .deleteTransactions(uid, transaction.id);
                              },
                              backgroundColor: AppColors.expense,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ],
                        ),
                        child: _transactionTile(
                          context,
                          title: transaction.title,
                          category: transaction.category,
                          amount: transaction.amount,
                          isIncome: isIncome,
                          date: transaction.timestamp,
                        ),
                      );
                    },
                    childCount: filteredTransactions.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, TransactionFilter filter) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(transactionFilterProvider.notifier).update(
                      (f) => f.copyWith(searchQuery: value),
                    );
              },
              decoration: const InputDecoration(
                hintText: "Search title or category...",
                hintStyle: TextStyle(
                  color: AppColors.textPlaceholder,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                filled: false,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textMuted,
              ),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                ref.read(transactionFilterProvider.notifier).update(
                      (f) => f.copyWith(searchQuery: ''),
                    );
              },
            ),
          Container(
            height: 24,
            width: 1,
            color: AppColors.border,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: filter.activeFilterCount > 0,
              label: Text(
                '${filter.activeFilterCount}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.tune_rounded,
                color: filter.activeFilterCount > 0
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            tooltip: 'Filter options',
            onPressed: () => TransactionFilterSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildQuickTypeSelector(TransactionFilter filter) {
    return Row(
      children: [
        _quickTypeChip('All', 'all', filter.type == 'all'),
        const SizedBox(width: 8),
        _quickTypeChip(
          'Income',
          'income',
          filter.type == 'income',
          activeColor: AppColors.income,
        ),
        const SizedBox(width: 8),
        _quickTypeChip(
          'Expense',
          'expense',
          filter.type == 'expense',
          activeColor: AppColors.expense,
        ),
      ],
    );
  }

  Widget _quickTypeChip(
    String label,
    String value,
    bool isSelected, {
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(transactionFilterProvider.notifier).update(
                (f) => f.copyWith(type: value),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(TransactionFilter filter) {
    final chips = <Widget>[];

    if (filter.category != null &&
        filter.category!.isNotEmpty &&
        filter.category != 'All') {
      chips.add(
        Chip(
          label: Text('Category: ${filter.category}'),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: () {
            ref.read(transactionFilterProvider.notifier).update(
                  (f) => f.copyWith(clearCategory: true),
                );
          },
        ),
      );
    }

    if (filter.startDate != null || filter.endDate != null) {
      final start = filter.startDate != null
          ? DateFormat('dd/MM').format(filter.startDate!)
          : 'Start';
      final end = filter.endDate != null
          ? DateFormat('dd/MM').format(filter.endDate!)
          : 'End';
      chips.add(
        Chip(
          label: Text('Date: $start - $end'),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: () {
            ref.read(transactionFilterProvider.notifier).update(
                  (f) => f.copyWith(clearStartDate: true, clearEndDate: true),
                );
          },
        ),
      );
    }

    if (filter.minAmount != null || filter.maxAmount != null) {
      final minStr = filter.minAmount != null
          ? '₹${filter.minAmount!.toStringAsFixed(0)}'
          : '₹0';
      final maxStr = filter.maxAmount != null
          ? '₹${filter.maxAmount!.toStringAsFixed(0)}'
          : '∞';
      chips.add(
        Chip(
          label: Text('Amount: $minStr - $maxStr'),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: () {
            ref.read(transactionFilterProvider.notifier).update(
                  (f) => f.copyWith(clearMinAmount: true, clearMaxAmount: true),
                );
          },
        ),
      );
    }

    if (filter.sortBy != 'newest') {
      String sortLabel;
      switch (filter.sortBy) {
        case 'oldest':
          sortLabel = 'Sort: Oldest First';
          break;
        case 'highest':
          sortLabel = 'Sort: Highest Amount';
          break;
        case 'lowest':
          sortLabel = 'Sort: Lowest Amount';
          break;
        default:
          sortLabel = 'Sort: Custom';
      }
      chips.add(
        Chip(
          label: Text(sortLabel),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: () {
            ref.read(transactionFilterProvider.notifier).update(
                  (f) => f.copyWith(resetSort: true),
                );
          },
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...chips.map(
            (chip) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: chip,
            ),
          ),
          ActionChip(
            label: const Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.expenseBg,
            side: BorderSide(
              color: AppColors.expense.withValues(alpha: 0.5),
            ),
            onPressed: _clearAllFilters,
          ),
        ],
      ),
    );
  }

  Widget _emptyFilteredTransactions() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "No Transactions Found",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Try adjusting your search terms or filter criteria",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Reset All Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(
    BuildContext context,
    double balance,
    double income,
    double expense,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "₹ ${balance.toStringAsFixed(2)}",
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _balanceItem(
                  title: "Income",
                  amount: income,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.income,
                ),
              ),
              Container(height: 48, width: 1, color: Colors.white24),
              Expanded(
                child: _balanceItem(
                  title: "Expense",
                  amount: expense,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "₹ ${amount.toStringAsFixed(2)}",
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(
    BuildContext context, {
    required String title,
    required String category,
    required double amount,
    required bool isIncome,
    required DateTime date,
  }) {
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: isIncome ? AppColors.incomeBg : AppColors.expenseBg,
          child: Icon(
            isIncome
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: color,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              "${date.day.toString().padLeft(2, '0')}/"
              "${date.month.toString().padLeft(2, '0')}/"
              "${date.year}",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        trailing: Text(
          "${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _emptyTransactions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 55,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              "No Transactions Yet",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              "Tap + to add your first transaction",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    showDialog(
      context: context,
      builder: (_) => EditTransactionDialog(transaction: transaction),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Log Out",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authServiceProvider).logOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
