import 'package:expense_tracker/services/receipt_scanner_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  final service = ReceiptScannerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
