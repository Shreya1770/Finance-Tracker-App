import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/widgets/add_budget_dialog.dart';
import 'package:expense_tracker/widgets/edit_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  String get _currentMonthKey =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _resetToCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = DateTime(now.year, now.month);
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'cosmetics':
        return Icons.brush_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'health':
        return Icons.favorite_outline;
      case 'houserent':
      case 'rent':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  double _calculateCategorySpent(
    String category,
    List<TransactionModel> transactions,
  ) {
    double total = 0.0;
    for (final tx in transactions) {
      if (tx.type.toLowerCase() == 'expense' &&
          tx.category.trim().toLowerCase() == category.trim().toLowerCase() &&
          tx.timestamp.year == _selectedMonth.year &&
          tx.timestamp.month == _selectedMonth.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String uid,
    BudgetModel budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dialogBg,
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the ${budget.category} budget of ₹${budget.limit.toStringAsFixed(0)}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(budgetNotifierProvider.notifier)
          .deleteBudget(uid, budget.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${budget.category} budget deleted'),
            backgroundColor: AppColors.snackBarBg,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text('Please log in to manage budgets'),
        ),
      );
    }
    final uid = user.uid;

    final budgetsAsync = ref.watch(budgetStreamProvider(uid));
    final transactionsAsync = ref.watch(transactionStreamProvider(uid));

    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Budget Management'),
        actions: [
          IconButton(
            tooltip: 'Add Budget',
            icon: const Icon(Icons.add_circle_outline, size: 26),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddBudgetDialog(initialMonth: _currentMonthKey),
              );
            },
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.expense),
            ),
          ),
        ),
        data: (allBudgets) {
          final monthBudgets = allBudgets
              .where((b) => b.month == _currentMonthKey)
              .toList();

          return transactionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading transactions:\n$error',
                  style: const TextStyle(color: AppColors.expense),
                ),
              ),
            ),
            data: (allTransactions) {
              // Precompute spent and status for each budget
              final budgetStats = monthBudgets.map((b) {
                final spent = _calculateCategorySpent(b.category, allTransactions);
                final status = b.getStatus(spent);
                final remaining = b.getRemaining(spent);
                final pct = b.getPercentage(spent);
                return (
                  budget: b,
                  spent: spent,
                  status: status,
                  remaining: remaining,
                  percentage: pct,
                );
              }).toList();

              // Calculate overall summary
              double totalLimit = 0.0;
              double totalSpent = 0.0;
              int exceededCount = 0;
              int warningCount = 0;

              for (final stat in budgetStats) {
                totalLimit += stat.budget.limit;
                totalSpent += stat.spent;
                if (stat.status == BudgetStatus.exceeded) {
                  exceededCount++;
                } else if (stat.status == BudgetStatus.warning) {
                  warningCount++;
                }
              }

              final totalRemaining = totalLimit - totalSpent;
              final overallPercentage =
                  totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0.0;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                children: [
                  // 1. Month Selector Header
                  _buildMonthSelector(isCurrentMonth),

                  const SizedBox(height: 16),

                  // 2. Budget Alerts Banner (if any warning or exceeded)
                  if (exceededCount > 0 || warningCount > 0) ...[
                    _buildAlertBanner(exceededCount, warningCount),
                    const SizedBox(height: 16),
                  ],

                  // 3. Overall Monthly Summary Card (if budgets exist)
                  if (monthBudgets.isNotEmpty) ...[
                    _buildSummaryCard(
                      totalLimit: totalLimit,
                      totalSpent: totalSpent,
                      totalRemaining: totalRemaining,
                      overallPercentage: overallPercentage,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 4. Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category Budgets',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${monthBudgets.length} configured',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 5. Category Budgets List or Empty State
                  if (monthBudgets.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...budgetStats.map(
                      (stat) => _buildBudgetCard(
                        context: context,
                        uid: uid,
                        budget: stat.budget,
                        spent: stat.spent,
                        status: stat.status,
                        remaining: stat.remaining,
                        percentage: stat.percentage,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(bool isCurrentMonth) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            tooltip: 'Previous Month',
            onPressed: _previousMonth,
          ),
          InkWell(
            onTap: isCurrentMonth ? null : _resetToCurrentMonth,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!isCurrentMonth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            tooltip: 'Next Month',
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(int exceededCount, int warningCount) {
    final bool hasExceeded = exceededCount > 0;
    final Color bannerColor =
        hasExceeded ? AppColors.expenseBg : AppColors.warningBg;
    final Color borderColor =
        hasExceeded ? AppColors.danger : AppColors.warning;
    final IconData icon =
        hasExceeded ? Icons.warning_amber_rounded : Icons.info_outline;

    String alertText;
    if (hasExceeded && warningCount > 0) {
      alertText =
          '$exceededCount category limit exceeded & $warningCount approaching limit!';
    } else if (hasExceeded) {
      alertText =
          '$exceededCount ${exceededCount == 1 ? 'category has' : 'categories have'} exceeded budget limit!';
    } else {
      alertText =
          '$warningCount ${warningCount == 1 ? 'category is' : 'categories are'} nearing limit (>80% spent).';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alertText,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalLimit,
    required double totalSpent,
    required double totalRemaining,
    required double overallPercentage,
  }) {
    final isOver = totalRemaining < 0;
    final progress = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.danger;
    } else if (progress >= 0.8) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.secondary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget Overview',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${overallPercentage.toStringAsFixed(1)}% Used',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${totalSpent.toStringAsFixed(0)} / ₹${totalLimit.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? 'Exceeded by ₹${(-totalRemaining).toStringAsFixed(0)}'
                    : 'Remaining: ₹${totalRemaining.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isOver ? Colors.white : Colors.white70,
                  fontWeight: isOver ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                isOver ? '⚠️ Over Budget' : (progress >= 0.8 ? '⚡ Caution' : '✓ On Track'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required BuildContext context,
    required String uid,
    required BudgetModel budget,
    required double spent,
    required BudgetStatus status,
    required double remaining,
    required double percentage,
  }) {
    final progress = budget.limit > 0 ? (spent / budget.limit).clamp(0.0, 1.0) : 0.0;

    Color statusColor;
    String statusLabel;
    Color statusBg;

    switch (status) {
      case BudgetStatus.exceeded:
        statusColor = AppColors.danger;
        statusLabel = 'Exceeded (${percentage.toStringAsFixed(0)}%)';
        statusBg = AppColors.expenseBg;
        break;
      case BudgetStatus.warning:
        statusColor = AppColors.warning;
        statusLabel = 'Near Limit (${percentage.toStringAsFixed(0)}%)';
        statusBg = AppColors.warningBg;
        break;
      case BudgetStatus.normal:
        statusColor = AppColors.income;
        statusLabel = '${percentage.toStringAsFixed(0)}% Used';
        statusBg = AppColors.incomeBg;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(budget.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                showDialog(
                  context: context,
                  builder: (_) => EditBudgetDialog(budget: budget),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius: BorderRadius.circular(16),
            ),
            SlidableAction(
              onPressed: (_) => _confirmDelete(context, uid, budget),
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: status == BudgetStatus.exceeded
                  ? AppColors.danger.withValues(alpha: 0.5)
                  : (status == BudgetStatus.warning
                      ? AppColors.warning.withValues(alpha: 0.4)
                      : AppColors.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Icon, Category Name, Status Badge, Edit Menu
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusBg,
                    child: Icon(
                      _getCategoryIcon(budget.category),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${spent.toStringAsFixed(0)} spent of ₹${budget.limit.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    color: AppColors.dialogBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (_) => EditBudgetDialog(budget: budget),
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(context, uid, budget);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.expense),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.expense)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: AppColors.inputBg,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 10),

              // Bottom status text: Remaining or Over budget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remaining < 0
                        ? 'Over by ₹${(-remaining).toStringAsFixed(0)}'
                        : '₹${remaining.toStringAsFixed(0)} remaining',
                    style: TextStyle(
                      color: remaining < 0 ? AppColors.danger : AppColors.textMuted,
                      fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Limit: ₹${budget.limit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Budgets for $monthName',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set category budgets to control your spending and receive alerts when you approach limits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddBudgetDialog(initialMonth: _currentMonthKey),
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Set First Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
