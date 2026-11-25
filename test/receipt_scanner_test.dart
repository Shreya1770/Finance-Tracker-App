import 'package:expense_tracker/services/receipt_scanner_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ReceiptScannerService scanner;

  setUp(() {
    scanner = ReceiptScannerService();
  });

  tearDown(() {
    scanner.dispose();
  });

  group('ReceiptScannerService Parser Unit Tests', () {
    test('Correctly extracts total amount, date, and merchant from standard receipt', () {
      const receiptText = '''
STARBUCKS COFFEE #1042
123 Market Street, San Francisco
Date: 15/11/2026 10:45 AM
Order: 49281

1x Iced Caramel Macchiato    5.75
1x Croissant                 3.50
Subtotal                     9.25
Tax                          0.80
Total                       \$10.05
Cash Paid                   \$20.00
Change                       9.95

Thank you for visiting!
''';

      final result = scanner.parseReceiptText(receiptText);

      expect(result.amount, 10.05);
      expect(result.merchant, 'STARBUCKS COFFEE #1042');
      expect(result.date, DateTime(2026, 11, 15));
      expect(result.suggestedCategory, 'Food');
      expect(result.hasData, isTrue);
    });

    test('Parses Indian supermarket receipt with INR/Rs currency and DD-MM-YYYY date', () {
      const receiptText = '''
RELIANCE FRESH
Bandra West, Mumbai
GSTIN: 27AABCR1234F1Z5
Date: 20-11-2026 Time: 19:30

Items:
Amul Milk 1L                 66.00
Brown Bread 400g             45.00
Tata Tea Gold               140.00
Total Items: 3
Net Amount:              Rs. 251.00
Mode of Payment: UPI
''';

      final result = scanner.parseReceiptText(receiptText);

      expect(result.amount, 251.0);
      expect(result.merchant, 'RELIANCE FRESH');
      expect(result.date, DateTime(2026, 11, 20));
      expect(result.suggestedCategory, 'Food');
    });

    test('Parses Uber transport trip receipt', () {
      const receiptText = '''
Uber India Systems Pvt Ltd
Trip Date: 12/11/2026
Ride from Airport to Home

Base Fare                   150.00
Distance (14.2 km)          280.00
Toll Charges                 60.00
Grand Total                 ₹490.00
Paid with Paytm
''';

      final result = scanner.parseReceiptText(receiptText);

      expect(result.amount, 490.0);
      expect(result.date, DateTime(2026, 11, 12));
      expect(result.suggestedCategory, 'Travel');
    });

    test('Parses Medical / Pharmacy bill and suggests Health category', () {
      const receiptText = '''
APOLLO PHARMACY
MG Road, Bangalore
Tax Invoice #4920
Date: 08-11-2026

Paracetamol 650mg            35.00
Vitamin C Tablets           120.00
Cough Syrup                 110.00
Amount Payable:             265.00
''';

      final result = scanner.parseReceiptText(receiptText);

      expect(result.amount, 265.0);
      expect(result.merchant, 'APOLLO PHARMACY');
      expect(result.date, DateTime(2026, 11, 8));
      expect(result.suggestedCategory, 'Health');
    });

    test('Handles empty or invalid text safely without crashing', () {
      final emptyResult = scanner.parseReceiptText('');
      expect(emptyResult.amount, isNull);
      expect(emptyResult.date, isNull);
      expect(emptyResult.merchant, isNull);
      expect(emptyResult.hasData, isFalse);

      final garbageResult = scanner.parseReceiptText('Welcome to our store\nHave a nice day');
      expect(garbageResult.amount, isNull);
      expect(garbageResult.date, isNull);
    });
  });
}
