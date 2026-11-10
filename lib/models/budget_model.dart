enum BudgetStatus { normal, warning, exceeded }

class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final String month;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return BudgetModel(
      id: id,
      category: map['category'] ?? '',
      limit: (map['limit'] as num?)?.toDouble() ?? 0.0,
      month: map['month'] ?? '',
    );
  }

  BudgetModel copyWith({
    String? id,
    String? category,
    double? limit,
    String? month,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      month: month ?? this.month,
    );
  }

  BudgetStatus getStatus(double spent) {
    if (limit <= 0) return BudgetStatus.normal;
    final ratio = spent / limit;
    if (ratio >= 1.0) return BudgetStatus.exceeded;
    if (ratio >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  double getPercentage(double spent) {
    if (limit <= 0) return 0.0;
    return (spent / limit) * 100.0;
  }

  double getRemaining(double spent) {
    return limit - spent;
  }
}
