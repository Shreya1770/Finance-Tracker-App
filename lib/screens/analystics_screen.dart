import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String selectedFilter = "This Year";
  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();

    DateTime startDate;

    switch (selectedFilter) {
      case "This Month":
        startDate = DateTime(now.year, now.month, 1);
        break;

      case "Last Month":
        startDate = DateTime(now.year, now.month - 1, 1);
        break;

      case "Last 3 Months":
        startDate = DateTime(now.year, now.month - 2, 1);
        break;

      case "This Year":
        startDate = DateTime(now.year, 1, 1);
        break;

      case "All Time":
        return transactions;

      default:
        return transactions;
    }

    return transactions.where((transaction) {
      return !transaction.timestamp.isBefore(startDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          final filteredTransactions = _filterTransactions(transactions);

          final Map<String, double> monthlyIncome = {};
          final Map<String, double> monthlyExpense = {};

          for (final transaction in filteredTransactions) {
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

          for (final transaction in filteredTransactions) {
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

          final months = {
            ...monthlyIncome.keys,
            ...monthlyExpense.keys,
          }.toList();

          months.sort();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedFilter,
                  decoration: const InputDecoration(
                    labelText: "Time Period",
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "This Month",
                      child: Text("This Month"),
                    ),
                    DropdownMenuItem(
                      value: "Last Month",
                      child: Text("Last Month"),
                    ),
                    DropdownMenuItem(
                      value: "Last 3 Months",
                      child: Text("Last 3 Months"),
                    ),
                    DropdownMenuItem(
                      value: "This Year",
                      child: Text("This Year"),
                    ),
                    DropdownMenuItem(
                      value: "All Time",
                      child: Text("All Time"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedFilter = value;
                    });
                  },
                ),

                const SizedBox(height: 25),
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
                const SizedBox(height: 25),

                // INCOME VS EXPENSE
                Text(
                  "Income vs Expense",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 20),

                if (months.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        "No income or expense data yet",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,

                    child: BarChart(
                      BarChartData(
                        // BAR GROUPS

                        barGroups: months.asMap().entries.map((entry) {
                          final index = entry.key;

                          final month = entry.value;

                          final income = monthlyIncome[month] ?? 0;

                          final expense = monthlyExpense[month] ?? 0;

                          return BarChartGroupData(
                            x: index,

                            barsSpace: 6,

                            barRods: [
                              // INCOME BAR
                              BarChartRodData(
                                toY: income,
                                width: 12,
                                color: AppColors.income,
                                borderRadius: BorderRadius.circular(4),
                              ),

                              // EXPENSE BAR
                              BarChartRodData(
                                toY: expense,
                                width: 12,
                                color: AppColors.expense,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),

                        // GRID
                        gridData: const FlGridData(show: true),

                        // BORDER
                        borderData: FlBorderData(show: false),

                        // X AXIS
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              reservedSize: 35,

                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();

                                if (index < 0 || index >= months.length) {
                                  return const SizedBox();
                                }

                                final parts = months[index].split("-");

                                final month = int.parse(parts[1]);

                                const monthNames = [
                                  "Jan",
                                  "Feb",
                                  "Mar",
                                  "Apr",
                                  "May",
                                  "Jun",
                                  "Jul",
                                  "Aug",
                                  "Sep",
                                  "Oct",
                                  "Nov",
                                  "Dec",
                                ];

                                return Text(
                                  monthNames[month - 1],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                // LEGEND
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    _buildLegend(AppColors.income, "Income"),

                    const SizedBox(width: 25),

                    _buildLegend(AppColors.expense, "Expense"),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // LEGEND

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(text),
      ],
    );
  }
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
