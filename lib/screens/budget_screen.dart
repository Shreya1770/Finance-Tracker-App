import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(authServiceProvider).currentUser!.uid;

    final budgetsAsync = ref.watch(
      budgetStreamProvider(uid),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Something went wrong:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.expense,
            ),
          ),
        ),
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(
              child: Text(
                'No budgets yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];

              return Card(
                child: ListTile(
                  title: Text(budget.category),
                  subtitle: Text(
                    '₹${budget.limit.toStringAsFixed(2)}',
                  ),
                  trailing: Text(budget.month),
                ),
              );
            },
          );
        },
      ),
    );
  }
}