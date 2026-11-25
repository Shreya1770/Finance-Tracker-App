import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/export_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExportStatementDialog extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;

  const ExportStatementDialog({
    super.key,
    required this.transactions,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TransactionModel> transactions,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ExportStatementDialog(transactions: transactions),
    );
  }

  @override
  ConsumerState<ExportStatementDialog> createState() =>
      _ExportStatementDialogState();
}

class _ExportStatementDialogState
    extends ConsumerState<ExportStatementDialog> {
  String _selectedFormat = 'pdf'; // 'pdf' or 'csv'
  String _selectedPeriod = 'all'; // 'all', 'this_month', 'last_month', 'custom'
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _applyPeriod('all');
  }

  void _applyPeriod(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'this_month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'last_month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'all':
        default:
          _startDate = null;
          _endDate = null;
          break;
      }
    });
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.dialogBg,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _startDate = picked.start;
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });
    }
  }

  List<TransactionModel> _getFilteredTransactions() {
    return widget.transactions.where((tx) {
      if (_startDate != null && tx.timestamp.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && tx.timestamp.isAfter(_endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _handlePreviewPdf(String userName) async {
    final toExport = _getFilteredTransactions();
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.previewPdf(
        userName: userName,
        transactions: toExport,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF preview: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleShare(String userName) async {
    final toExport = _getFilteredTransactions();
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      if (_selectedFormat == 'pdf') {
        await exportService.sharePdf(
          userName: userName,
          transactions: toExport,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await exportService.shareCsv(transactions: toExport);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredTransactions();
    final firstName = ref.watch(firstNameProvider).value ?? 'User';

    return AlertDialog(
      backgroundColor: AppColors.dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.file_download_outlined,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Export Statement',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Format Selection
            const Text(
              'Export Format',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFormatCard(
                    title: 'PDF Document',
                    subtitle: 'Statement with summary',
                    format: 'pdf',
                    icon: Icons.picture_as_pdf_rounded,
                    accentColor: AppColors.expense,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFormatCard(
                    title: 'CSV File',
                    subtitle: 'Excel & Google Sheets',
                    format: 'csv',
                    icon: Icons.table_chart_rounded,
                    accentColor: AppColors.income,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Period Selection
            const Text(
              'Select Period',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeriodChip('All Time', 'all'),
                _buildPeriodChip('This Month', 'this_month'),
                _buildPeriodChip('Last Month', 'last_month'),
                _buildCustomRangeChip(),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Records Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${filtered.length} transactions included',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_startDate != null && _endDate != null)
                    Text(
                      '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        if (_selectedFormat == 'pdf')
          OutlinedButton.icon(
            onPressed:
                _isExporting ? null : () => _handlePreviewPdf(firstName),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('Preview'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : () => _handleShare(firstName),
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.share_rounded, size: 16),
          label: Text(_isExporting ? 'Generating...' : 'Export & Share'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatCard({
    required String title,
    required String subtitle,
    required String format,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryMuted
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: accentColor),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyPeriod(period);
        }
      },
      selectedColor: AppColors.primaryMuted,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildCustomRangeChip() {
    final isSelected = _selectedPeriod == 'custom';

    return ChoiceChip(
      avatar: const Icon(Icons.date_range, size: 14),
      label: const Text('Custom...'),
      selected: isSelected,
      onSelected: (_) => _pickCustomRange(),
      selectedColor: AppColors.primaryMuted,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
