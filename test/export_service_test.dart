import 'dart:convert';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExportService exportService;

  setUp(() {
    exportService = ExportService();
  });

  final sampleTransactions = [
    TransactionModel(
      id: 'tx_01',
      title: 'Salary Deposit',
      amount: 75000.0,
      type: 'income',
      category: 'Salary',
      timestamp: DateTime(2026, 11, 1, 10, 0),
    ),
    TransactionModel(
      id: 'tx_02',
      title: 'Groceries Mart',
      amount: 4500.0,
      type: 'expense',
      category: 'Food',
      timestamp: DateTime(2026, 11, 5, 14, 30),
    ),
    TransactionModel(
      id: 'tx_03',
      title: 'Internet & WiFi Bill',
      amount: 1200.0,
      type: 'expense',
      category: 'Bills',
      timestamp: DateTime(2026, 11, 10, 18, 0),
    ),
  ];

  group('ExportService Tests', () {
    test('generatePdfStatement produces valid non-empty PDF document bytes', () async {
      final bytes = await exportService.generatePdfStatement(
        userName: 'Alex Johnson',
        transactions: sampleTransactions,
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 30),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));

      // PDF files always begin with the magic header bytes '%PDF-'
      final header = ascii.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generatePdfStatement handles empty transaction lists gracefully', () async {
      final bytes = await exportService.generatePdfStatement(
        userName: 'Alex Johnson',
        transactions: [],
      );

      expect(bytes, isNotEmpty);
      final header = ascii.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generateCsvString produces properly structured and comma-separated rows', () {
      final csvString = exportService.generateCsvString(sampleTransactions);

      expect(csvString, contains('ID,Date,Title,Category,Type,Amount'));
      expect(csvString, contains('tx_01,2026-11-01 10:00,Salary Deposit,Salary,income,75000.0'));
      expect(csvString, contains('tx_02,2026-11-05 14:30,Groceries Mart,Food,expense,4500.0'));
      expect(csvString, contains('tx_03,2026-11-10 18:00,Internet & WiFi Bill,Bills,expense,1200.0'));

      final lines = csvString.trim().split('\n');
      expect(lines.length, equals(4)); // Header + 3 transactions
    });
  });
}
