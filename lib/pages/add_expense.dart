import 'package:expen/core/theme.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  final bool isIncome;
  const AddExpense({super.key, this.isIncome = false});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  late bool _isIncome;
  String? _selectedCategory;
  String _selectedPaymentMethod = "Cash";

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  final List<String> _paymentMethods = const [
    "Cash",
    "Card",
    "UPI",
    "Net Banking",
  ];

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isIncome;
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction(AmountProvider amountProvider, String currencySymbol) {
    var amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    double? amountValue = double.tryParse(amountText);
    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a positive numeric amount")),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    // Save
    amountProvider.addAmount(
      _selectedCategory!,
      _notesController.text.trim(),
      amountValue,
      _selectedDate,
      isIncome: _isIncome,
      paymentMethod: _selectedPaymentMethod,
    );

    // If it was an expense, check if it goes near/over budget and alert user
    if (!_isIncome) {
      var limit = amountProvider.getBudgetLimit(_selectedCategory!);
      if (limit > 0) {
        var currentSpent =
            amountProvider.getCategoryMonthlySpending(_selectedCategory!) +
            amountValue;
        if (currentSpent > limit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Budget Exceeded for $_selectedCategory! ($currencySymbol${currentSpent.toStringAsFixed(0)} / $currencySymbol${limit.toStringAsFixed(0)})",
              ),
              backgroundColor: AppColors.expense,
            ),
          );
        } else if (currentSpent >= limit * 0.85) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Warning: Near budget limit for $_selectedCategory!",
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var categories = amountProvider.allCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Transaction"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sliding Selector: Expense / Income
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkCard : AppColors.lightTransparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isIncome = false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                !_isIncome
                                    ? AppColors.expense
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Expense",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  !_isIncome
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isIncome = true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                _isIncome
                                    ? AppColors.income
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Income",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _isIncome
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Large Numeric Amount display
              Center(
                child: SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "0.00",
                      prefixText: currencyProvider.selectedCurrencySymbol,
                      prefixStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Category Chip Grid
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    categories.map((c) {
                      var isSelected = _selectedCategory == c;
                      var color = CategoryStyle.getColor(c);
                      return FilterChip(
                        label: Text(c),
                        avatar: Icon(
                          CategoryStyle.getIcon(c),
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = val ? c : null;
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Date selection
              const Text(
                "Date",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: premiumCardDeco(isDark: isDark),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textMutedDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Payment Method Selector
              const Text(
                "Payment Method",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children:
                    _paymentMethods.map((m) {
                      var isSelected = _selectedPaymentMethod == m;
                      return ChoiceChip(
                        label: Text(m),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedPaymentMethod = m;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // 6. Notes Input
              const Text(
                "Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: "Add description or tags...",
                ),
              ),
              const SizedBox(height: 36),

              // 7. Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor:
                      _isIncome ? AppColors.income : AppColors.expense,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    () => _saveTransaction(
                      amountProvider,
                      currencyProvider.selectedCurrencySymbol,
                    ),
                child: const Text(
                  "Save Transaction",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
