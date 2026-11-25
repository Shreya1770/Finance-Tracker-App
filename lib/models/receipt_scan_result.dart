class ReceiptScanResult {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String? suggestedCategory;
  final String rawText;

  const ReceiptScanResult({
    this.amount,
    this.date,
    this.merchant,
    this.suggestedCategory,
    required this.rawText,
  });

  bool get hasData =>
      amount != null ||
      date != null ||
      (merchant != null && merchant!.isNotEmpty);
}
