import 'dart:io';
import 'package:expense_tracker/models/receipt_scan_result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerService {
  final ImagePicker _picker;
  TextRecognizer? _recognizer;

  ReceiptScannerService({
    ImagePicker? picker,
    TextRecognizer? recognizer,
  })  : _picker = picker ?? ImagePicker(),
        _recognizer = recognizer;

  TextRecognizer get _textRecognizer =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  /// Picks an image from camera or gallery and extracts receipt details.
  Future<ReceiptScanResult?> scanReceipt({
    required ImageSource source,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (file == null) {
        return null;
      }

      final inputImage = InputImage.fromFile(File(file.path));
      final RecognizedText recognized =
          await _textRecognizer.processImage(inputImage);

      return parseReceiptText(recognized.text);
    } catch (e) {
      return null;
    }
  }

  /// Pure text parsing algorithm to extract amount, date, merchant, and category.
  ReceiptScanResult parseReceiptText(String rawText) {
    if (rawText.trim().isEmpty) {
      return const ReceiptScanResult(rawText: '');
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final double? amount = _extractAmount(lines);
    final DateTime? date = _extractDate(lines);
    final String? merchant = _extractMerchant(lines);
    final String? category = _suggestCategory(rawText, merchant);

    return ReceiptScanResult(
      amount: amount,
      date: date,
      merchant: merchant,
      suggestedCategory: category,
      rawText: rawText,
    );
  }

  /// Extracts the total transaction amount from lines.
  double? _extractAmount(List<String> lines) {
    // 1. High priority: Lines containing total keywords
    final totalKeywords = [
      'grand total',
      'total amount',
      'net amount',
      'amount payable',
      'balance due',
      'bill amount',
      'final amount',
      'total',
      'subtotal',
      'amount',
    ];

    for (final keyword in totalKeywords) {
      for (final line in lines.reversed) {
        final lower = line.toLowerCase();
        if (lower.contains(keyword)) {
          final found = _extractNumbersFromLine(line);
          if (found.isNotEmpty) {
            found.sort();
            final best = found.last;
            if (best > 0 && best < 10000000) {
              return best;
            }
          }
        }
      }
    }

    // 2. Medium priority: Lines containing currency symbols (₹, $, €, £, Rs, INR)
    for (final line in lines.reversed) {
      final lower = line.toLowerCase();
      if (lower.contains('₹') ||
          lower.contains('\$') ||
          lower.contains('€') ||
          lower.contains('£') ||
          lower.contains('rs') ||
          lower.contains('inr')) {
        final found = _extractNumbersFromLine(line);
        if (found.isNotEmpty) {
          found.sort();
          return found.last;
        }
      }
    }

    // 3. Fallback: Find the maximum plausible number with decimal places
    final List<double> candidates = [];
    final decimalRegex = RegExp(r'\b\d+[\.,]\d{2}\b');

    for (final line in lines) {
      final matches = decimalRegex.allMatches(line);
      for (final m in matches) {
        final raw = m.group(0)!.replaceAll(',', '.');
        final val = double.tryParse(raw);
        if (val != null && val > 0 && val < 10000000) {
          candidates.add(val);
        }
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort();
      return candidates.last;
    }

    return null;
  }

  List<double> _extractNumbersFromLine(String line) {
    final List<double> numbers = [];
    final regExp = RegExp(
      r'(?:[\$₹€£]|rs\.?|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final matches = regExp.allMatches(line);

    for (final match in matches) {
      final matchedStr = match.group(1);
      if (matchedStr != null) {
        final clean = matchedStr.replaceAll(',', '');
        final val = double.tryParse(clean);
        // Exclude phone numbers, tax IDs, or barcodes
        if (val != null && val > 0 && clean.split('.').first.length <= 7) {
          numbers.add(val);
        }
      }
    }

    return numbers;
  }

  /// Extracts date from the receipt lines.
  DateTime? _extractDate(List<String> lines) {
    // Matches DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD
    final dateRegex = RegExp(r'\b(\d{1,4})[/\-\.](\d{1,2})[/\-\.](\d{2,4})\b');

    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        final p1 = int.tryParse(match.group(1)!);
        final p2 = int.tryParse(match.group(2)!);
        final p3 = int.tryParse(match.group(3)!);

        if (p1 != null && p2 != null && p3 != null) {
          // If p1 is 4-digit year: YYYY-MM-DD
          if (p1 >= 2000 && p1 <= 2035 && p2 >= 1 && p2 <= 12 && p3 >= 1 && p3 <= 31) {
            return DateTime(p1, p2, p3);
          }
          // If p3 is 4-digit year: DD-MM-YYYY
          if (p3 >= 2000 && p3 <= 2035 && p2 >= 1 && p2 <= 12 && p1 >= 1 && p1 <= 31) {
            return DateTime(p3, p2, p1);
          }
          // If p3 is 2-digit year (e.g. 26 -> 2026)
          if (p3 >= 20 && p3 <= 40 && p2 >= 1 && p2 <= 12 && p1 >= 1 && p1 <= 31) {
            return DateTime(2000 + p3, p2, p1);
          }
        }
      }
    }

    return null;
  }

  /// Extracts the merchant / store name.
  String? _extractMerchant(List<String> lines) {
    final ignoredWords = [
      'tax invoice',
      'invoice',
      'receipt',
      'bill',
      'welcome',
      'cash memo',
      'thank you',
      'date',
      'tel:',
      'phone',
      'gstin',
      'order',
    ];

    for (int i = 0; i < lines.length && i < 4; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      final hasIgnored = ignoredWords.any((w) => lower.contains(w));
      final hasDigitsOnly = RegExp(r'^[0-9\W]+$').hasMatch(line);

      if (!hasIgnored && !hasDigitsOnly && line.length >= 3 && line.length <= 40) {
        return line;
      }
    }

    return null;
  }

  /// Suggests a category based on receipt contents.
  String? _suggestCategory(String rawText, String? merchant) {
    final lower = '$rawText ${merchant ?? ''}'.toLowerCase();

    if (lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('cafe') ||
        lower.contains('coffee') ||
        lower.contains('kitchen') ||
        lower.contains('bakery') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('supermarket') ||
        lower.contains('grocery') ||
        lower.contains('mart') ||
        lower.contains('bistro') ||
        lower.contains('bar') ||
        lower.contains('dining') ||
        lower.contains('fresh')) {
      return 'Food';
    }

    if (lower.contains('uber') ||
        lower.contains('ola') ||
        lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('diesel') ||
        lower.contains('taxi') ||
        lower.contains('cab') ||
        lower.contains('flight') ||
        lower.contains('airline') ||
        lower.contains('railway') ||
        lower.contains('metro') ||
        lower.contains('toll')) {
      return 'Travel';
    }

    if (lower.contains('electricity') ||
        lower.contains('broadband') ||
        lower.contains('airtel') ||
        lower.contains('jio') ||
        lower.contains('vodafone') ||
        lower.contains('water') ||
        lower.contains('utility') ||
        lower.contains('recharge') ||
        lower.contains('gas bill')) {
      return 'Bills';
    }

    if (lower.contains('clothing') ||
        lower.contains('apparel') ||
        lower.contains('fashion') ||
        lower.contains('zara') ||
        lower.contains('h&m') ||
        lower.contains('shopping') ||
        lower.contains('retail') ||
        lower.contains('mall')) {
      return 'Shopping';
    }

    if (lower.contains('pharmacy') ||
        lower.contains('chemist') ||
        lower.contains('hospital') ||
        lower.contains('clinic') ||
        lower.contains('medical') ||
        lower.contains('medicine') ||
        lower.contains('dental') ||
        lower.contains('healthcare')) {
      return 'Health';
    }

    if (lower.contains('cinema') ||
        lower.contains('movie') ||
        lower.contains('theatre') ||
        lower.contains('netflix') ||
        lower.contains('game') ||
        lower.contains('entertainment')) {
      return 'Entertainment';
    }

    if (lower.contains('beauty') ||
        lower.contains('cosmetics') ||
        lower.contains('salon') ||
        lower.contains('spa') ||
        lower.contains('makeup') ||
        lower.contains('parlour')) {
      return 'Cosmetics';
    }

    if (lower.contains('rent') ||
        lower.contains('lease') ||
        lower.contains('maintenance')) {
      return 'HouseRent';
    }

    return null;
  }

  void dispose() {
    _recognizer?.close();
  }
}
