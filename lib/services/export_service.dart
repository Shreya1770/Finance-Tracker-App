import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Generates a branded, professionally styled PDF financial statement.
  Future<Uint8List> generatePdfStatement({
    required String userName,
    required List<TransactionModel> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Calculate Financial Highlights
    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      if (tx.type.toLowerCase() == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type.toLowerCase() == 'expense') {
        totalExpense += tx.amount;
      }
    }

    final double netSavings = totalIncome - totalExpense;
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs. ',
      decimalDigits: 2,
    );

    String dateRangeStr = 'All Recorded Transactions';
    if (startDate != null && endDate != null) {
      dateRangeStr =
          '${dateFormat.format(startDate)}  to  ${dateFormat.format(endDate)}';
    } else if (startDate != null) {
      dateRangeStr = 'From ${dateFormat.format(startDate)}';
    } else if (endDate != null) {
      dateRangeStr = 'Up to ${dateFormat.format(endDate)}';
    }

    // Color Palette for PDF
    final primaryColor = PdfColor.fromHex('#4F46E5'); // Indigo
    final incomeColor = PdfColor.fromHex('#10B981'); // Emerald
    final expenseColor = PdfColor.fromHex('#EF4444'); // Crimson
    final textColor = PdfColor.fromHex('#1E293B');
    final subtleTextColor = PdfColor.fromHex('#64748B');
    final cardBgColor = PdfColor.fromHex('#F8FAFC');
    final borderColor = PdfColor.fromHex('#E2E8F0');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(
          context: context,
          userName: userName,
          dateRangeStr: dateRangeStr,
          primaryColor: primaryColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        ),
        footer: (context) => _buildPdfFooter(
          context: context,
          subtleTextColor: subtleTextColor,
          borderColor: borderColor,
        ),
        build: (context) => [
          pw.SizedBox(height: 16),

          // 1. Financial Highlights Summary Cards
          _buildSummaryCards(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            netSavings: netSavings,
            txCount: transactions.length,
            currencyFormat: currencyFormat,
            incomeColor: incomeColor,
            expenseColor: expenseColor,
            primaryColor: primaryColor,
            cardBgColor: cardBgColor,
            borderColor: borderColor,
          ),

          pw.SizedBox(height: 24),

          // 2. Transaction Table Title
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Transaction History',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor,
                ),
              ),
              pw.Text(
                '${transactions.length} Total Records',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: subtleTextColor,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // 3. Transactions Table
          _buildTransactionsTable(
            transactions: transactions,
            dateFormat: dateFormat,
            currencyFormat: currencyFormat,
            incomeColor: incomeColor,
            expenseColor: expenseColor,
            textColor: textColor,
            borderColor: borderColor,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfHeader({
    required pw.Context context,
    required String userName,
    required String dateRangeStr,
    required PdfColor primaryColor,
    required PdfColor textColor,
    required PdfColor subtleTextColor,
  }) {
    final generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 28,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'ET',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'EXPENSE TRACKER',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Personal Financial Statement',
                style: pw.TextStyle(fontSize: 12, color: subtleTextColor),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Account: $userName',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Period: $dateRangeStr',
                style: pw.TextStyle(fontSize: 10, color: subtleTextColor),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated: $generatedOn',
                style: pw.TextStyle(fontSize: 9, color: subtleTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter({
    required pw.Context context,
    required PdfColor subtleTextColor,
    required PdfColor borderColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Expense Tracker App - Confidential Financial Statement',
            style: pw.TextStyle(fontSize: 9, color: subtleTextColor),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: subtleTextColor),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCards({
    required double totalIncome,
    required double totalExpense,
    required double netSavings,
    required int txCount,
    required NumberFormat currencyFormat,
    required PdfColor incomeColor,
    required PdfColor expenseColor,
    required PdfColor primaryColor,
    required PdfColor cardBgColor,
    required PdfColor borderColor,
  }) {
    return pw.Row(
      children: [
        _buildStatBox(
          title: 'Total Income',
          value: currencyFormat.format(totalIncome),
          valueColor: incomeColor,
          cardBg: cardBgColor,
          borderColor: borderColor,
        ),
        pw.SizedBox(width: 10),
        _buildStatBox(
          title: 'Total Expense',
          value: currencyFormat.format(totalExpense),
          valueColor: expenseColor,
          cardBg: cardBgColor,
          borderColor: borderColor,
        ),
        pw.SizedBox(width: 10),
        _buildStatBox(
          title: 'Net Savings',
          value: currencyFormat.format(netSavings),
          valueColor: netSavings >= 0 ? incomeColor : expenseColor,
          cardBg: cardBgColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  pw.Widget _buildStatBox({
    required String title,
    required String value,
    required PdfColor valueColor,
    required PdfColor cardBg,
    required PdfColor borderColor,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: borderColor, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTransactionsTable({
    required List<TransactionModel> transactions,
    required DateFormat dateFormat,
    required NumberFormat currencyFormat,
    required PdfColor incomeColor,
    required PdfColor expenseColor,
    required PdfColor textColor,
    required PdfColor borderColor,
  }) {
    if (transactions.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(24),
        alignment: pw.Alignment.center,
        child: pw.Text(
          'No transactions found for the selected period.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      );
    }

    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
        bottom: pw.BorderSide(color: borderColor, width: 1),
      ),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#334155'),
        borderRadius: const pw.BorderRadius.vertical(
          top: pw.Radius.circular(6),
        ),
      ),
      headerHeight: 28,
      cellHeight: 26,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
      data: transactions.map((tx) {
        final isIncome = tx.type.toLowerCase() == 'income';
        final prefix = isIncome ? '+ ' : '- ';

        return [
          dateFormat.format(tx.timestamp),
          tx.title,
          tx.category,
          tx.type.toUpperCase(),
          prefix + currencyFormat.format(tx.amount),
        ];
      }).toList(),
      cellStyle: pw.TextStyle(
        fontSize: 9,
        color: textColor,
      ),
    );
  }

  /// Exports transactions to a CSV formatted string.
  String generateCsvString(List<TransactionModel> transactions) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final List<List<dynamic>> rows = [
      ['ID', 'Date', 'Title', 'Category', 'Type', 'Amount'],
    ];

    for (final tx in transactions) {
      rows.add([
        tx.id,
        dateFormat.format(tx.timestamp),
        tx.title,
        tx.category,
        tx.type,
        tx.amount,
      ]);
    }

    return csv.encode(rows);
  }

  /// Opens the native print & PDF preview screen.
  Future<void> previewPdf({
    required String userName,
    required List<TransactionModel> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Printing.layoutPdf(
      name: 'expense_statement_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      onLayout: (PdfPageFormat format) async {
        return generatePdfStatement(
          userName: userName,
          transactions: transactions,
          startDate: startDate,
          endDate: endDate,
        );
      },
    );
  }

  /// Saves or shares the generated PDF statement.
  Future<void> sharePdf({
    required String userName,
    required List<TransactionModel> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bytes = await generatePdfStatement(
      userName: userName,
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );

    final filename =
        'statement_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  /// Saves and shares transactions as a CSV spreadsheet.
  Future<void> shareCsv({
    required List<TransactionModel> transactions,
  }) async {
    final csvData = generateCsvString(transactions);
    final tempDir = await getTemporaryDirectory();
    final filename =
        'expense_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final file = File('${tempDir.path}/$filename');

    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        text: 'Expense Tracker CSV Statement',
      ),
    );
  }
}
