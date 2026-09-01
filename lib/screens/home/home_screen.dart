import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/analystics_screen.dart';
import 'package:expense_tracker/widgets/add_transaction_dialog.dart';
import 'package:expense_tracker/widgets/edit_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,


      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHomeContent(context), const AnalyticsScreen()],
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
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final uid = ref.read(authServiceProvider).currentUser!.uid;

    final transactionsAsync = ref.watch(transactionStreamProvider(uid));

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
                        padding: const EdgeInsets.only(left: 24, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            firstNameAsync.when(
                              data: (firstName) {
                                return Text(
                                  "Hey ${firstName ?? 'there'} 👋",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                );
                              },

                              loading: () {
                                return const Text(
                                  "Hey there 👋",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },

                              error: (_, __) {
                                return const Text(
                                  "Hey there 👋",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Transactions",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    // if (transactions.isNotEmpty)
                    //   TextButton(
                    //     onPressed: () {
                    //       // Implement see all action
                    //     },
                    //     child: const Text("See All"),
                    //   ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (transactions.isEmpty)
              SliverToBoxAdapter(child: _emptyTransactions(context))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final transaction = transactions[index];

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
                  }, childCount: transactions.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
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
            color: AppColors.primary.withOpacity(0.25),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),

            const SizedBox(height: 2),

            Text(
              "${date.day.toString().padLeft(2, '0')}/"
              "${date.month.toString().padLeft(2, '0')}/"
              "${date.year}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
      builder: (_) {
        return EditTransactionDialog(transaction: transaction);
      },
    );
  }
}
