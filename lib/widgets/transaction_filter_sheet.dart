import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TransactionFilterSheet(),
    );
  }

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  late String _selectedType;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  late String _sortBy;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;

  final List<String> _categories = [
    "All",
    "Food",
    "Travel",
    "Cosmetics",
    "Bills",
    "Salary",
    "Shopping",
    "Entertainment",
    "Health",
    "HouseRent",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(transactionFilterProvider);
    _selectedType = currentFilter.type;
    _selectedCategory = currentFilter.category ?? "All";
    _startDate = currentFilter.startDate;
    _endDate = currentFilter.endDate;
    _sortBy = currentFilter.sortBy;

    _minAmountController = TextEditingController(
      text: currentFilter.minAmount != null
          ? currentFilter.minAmount!.toStringAsFixed(
              currentFilter.minAmount!.truncateToDouble() ==
                      currentFilter.minAmount!
                  ? 0
                  : 2,
            )
          : '',
    );

    _maxAmountController = TextEditingController(
      text: currentFilter.maxAmount != null
          ? currentFilter.maxAmount!.toStringAsFixed(
              currentFilter.maxAmount!.truncateToDouble() ==
                      currentFilter.maxAmount!
                  ? 0
                  : 2,
            )
          : '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedCategory = 'All';
      _startDate = null;
      _endDate = null;
      _sortBy = 'newest';
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _setDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      switch (preset) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          _endDate = DateTime(now.year, now.month, now.day);
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'all':
        default:
          _startDate = null;
          _endDate = null;
          break;
      }
    });
  }

  Future<void> _pickDateRange() async {
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
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _applyFilters() {
    final minAmount = double.tryParse(_minAmountController.text.trim());
    final maxAmount = double.tryParse(_maxAmountController.text.trim());

    final current = ref.read(transactionFilterProvider);

    final updated = current.copyWith(
      type: _selectedType,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      clearCategory: _selectedCategory == 'All',
      startDate: _startDate,
      clearStartDate: _startDate == null,
      endDate: _endDate,
      clearEndDate: _endDate == null,
      minAmount: minAmount,
      clearMinAmount: minAmount == null,
      maxAmount: maxAmount,
      clearMaxAmount: maxAmount == null,
      sortBy: _sortBy,
    );

    ref.read(transactionFilterProvider.notifier).state = updated;
    Navigator.pop(context);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.apps_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'cosmetics':
        return Icons.brush_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'health':
        return Icons.favorite_outline;
      case 'houserent':
      case 'rent':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort Transactions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 1. Transaction Type
              const Text(
                'Transaction Type',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Income', 'income'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Expense', 'expense'),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Sort Order
              const Text(
                'Sort Order',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('Newest First', 'newest', Icons.access_time_filled),
                  _buildSortChip('Oldest First', 'oldest', Icons.history),
                  _buildSortChip('Highest Amount', 'highest', Icons.arrow_upward_rounded),
                  _buildSortChip('Lowest Amount', 'lowest', Icons.arrow_downward_rounded),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Category
              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    avatar: Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                    ),
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: AppColors.primaryMuted,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 4. Date Range
              const Text(
                'Date Range',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Date Presets
              Row(
                children: [
                  _buildDatePresetChip('All Time', 'all'),
                  const SizedBox(width: 6),
                  _buildDatePresetChip('Today', 'today'),
                  const SizedBox(width: 6),
                  _buildDatePresetChip('This Week', 'week'),
                  const SizedBox(width: 6),
                  _buildDatePresetChip('This Month', 'month'),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 20,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('dd MMM yyyy').format(_startDate!)}  —  ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                              : 'Select custom date range',
                          style: TextStyle(
                            color: _startDate != null
                                ? AppColors.textPrimary
                                : AppColors.textPlaceholder,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_startDate != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Amount Range
              const Text(
                'Amount Range (₹)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Min Amount',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 6. Apply Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;

    Color activeColor = AppColors.primary;
    if (value == 'income') activeColor = AppColors.income;
    if (value == 'expense') activeColor = AppColors.expense;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.2)
                : AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
          });
        }
      },
      selectedColor: AppColors.primaryMuted,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildDatePresetChip(String label, String preset) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _setDatePreset(preset),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
