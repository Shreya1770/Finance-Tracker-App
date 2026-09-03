import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(authServiceProvider).currentUser!.uid;
    final transactionsAsync = ref.watch(transactionStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),

      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: ((error, stack) => Center(child: Text("Error:$error"))),
        data: (transactions) {
          final Map<String, double> monthlyIncome = {};
          final Map<String, double> monthlyExpense = {};

          for (final transaction in transactions) {
            final month =
                "${transaction.timestamp.year}-${transaction.timestamp.month}";

            if (transaction.type == "income") {
              monthlyIncome[month] =
                  (monthlyIncome[month] ?? 0) + transaction.amount;
            } else if (transaction.type == "expense") {
              monthlyExpense[month] =
                  (monthlyExpense[month] ?? 0) + transaction.amount;
            }
          }

          print(monthlyIncome);
          print(monthlyExpense);

          final Map<String, double> categoryExpenses = {};

          for (final transaction in transactions) {
            if (transaction.type == "expense") {
              categoryExpenses[transaction.category] =
                  (categoryExpenses[transaction.category] ?? 0) +
                  transaction.amount;
            }
          }
          double totalExpense = 0;

          for (final amount in categoryExpenses.values) {
            totalExpense += amount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Expenses by Category",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 240,

                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,

                      sectionsSpace: 3,

                      sections: categoryExpenses.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final category = entry.value.key;
                            final amount = entry.value.value;

                            final percentage = (amount / totalExpense) * 100;

                            return PieChartSectionData(
                              value: amount,

                              title: "${percentage.toStringAsFixed(0)}%",

                              radius: 90,

                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),

                              color: _getChartColor(index),

                              showTitle: percentage >= 5,
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Category Breakdown",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                ...categoryExpenses.entries.map((entry) {
                  final percentage = (entry.value / totalExpense) * 100;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        "₹ ${entry.value.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${percentage.toStringAsFixed(1)}% of expenses",
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getChartColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.income,
      AppColors.warning,
      AppColors.expense,
      AppColors.primaryLight,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
    ];

    return colors[index % colors.length];
  }
}
