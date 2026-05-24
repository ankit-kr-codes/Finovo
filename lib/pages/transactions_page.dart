import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/core/theme.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  void _showFilterBottomSheet(BuildContext context, AmountProvider provider) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    String? tempCategory = provider.filterCategory;
    bool? tempIsIncome = provider.filterIsIncome;
    DateTimeRange? tempDateRange = provider.filterDateRange;
    var minController = TextEditingController(
      text: provider.filterMinAmount?.toString() ?? "",
    );
    var maxController = TextEditingController(
      text: provider.filterMaxAmount?.toString() ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text("Clear All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Transaction Type
                  const Text(
                    "Transaction Type",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _filterTypeChip(
                        label: "All",
                        isSelected: tempIsIncome == null,
                        onTap: () => setStateSheet(() => tempIsIncome = null),
                      ),
                      const SizedBox(width: 8),
                      _filterTypeChip(
                        label: "Income",
                        isSelected: tempIsIncome == true,
                        onTap: () => setStateSheet(() => tempIsIncome = true),
                      ),
                      const SizedBox(width: 8),
                      _filterTypeChip(
                        label: "Expense",
                        isSelected: tempIsIncome == false,
                        onTap: () => setStateSheet(() => tempIsIncome = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  const Text(
                    "Category",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: tempCategory,
                        hint: const Text("Select Category"),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(child: Text("All Categories")),
                          ...provider.allCategories.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                        onChanged:
                            (val) => setStateSheet(() => tempCategory = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Range Picker
                  const Text(
                    "Date Range",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color:
                            isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                      ),
                    ),
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(
                      tempDateRange == null
                          ? "Select Date Range"
                          : "${DateFormat('dd/MM/yyyy').format(tempDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(tempDateRange!.end)}",
                    ),
                    onPressed: () async {
                      var picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: tempDateRange,
                      );
                      if (picked != null) {
                        setStateSheet(() => tempDateRange = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Amount Range Filter
                  const Text(
                    "Amount Range",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Min",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Max",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Apply button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      double? minAmount = double.tryParse(minController.text);
                      double? maxAmount = double.tryParse(maxController.text);

                      provider.updateFilters(
                        category: tempCategory,
                        isIncome: tempIsIncome,
                        dateRange: tempDateRange,
                        minAmount: minAmount,
                        maxAmount: maxAmount,
                      );

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.borderLight.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    var isDark = Theme.of(context).brightness == Brightness.dark;

    var list = amountProvider.filteredAmounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context, amountProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search notes or categories...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            amountProvider.updateFilters(searchQuery: "");
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(),
              ),
              onChanged: (val) {
                setState(() {});
                amountProvider.updateFilters(searchQuery: val);
              },
            ),
          ),

          // Active Filters Display
          if (amountProvider.filterCategory != null ||
              amountProvider.filterIsIncome != null ||
              amountProvider.filterDateRange != null ||
              amountProvider.filterMinAmount != null ||
              amountProvider.filterMaxAmount != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text(
                        "Clear Filters",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        amountProvider.clearFilters();
                      },
                    ),
                    const SizedBox(width: 8),
                    if (amountProvider.filterCategory != null) ...[
                      Chip(
                        label: Text(
                          "Category: ${amountProvider.filterCategory}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => amountProvider.updateFilters(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (amountProvider.filterIsIncome != null) ...[
                      Chip(
                        label: Text(
                          amountProvider.filterIsIncome!
                              ? "Type: Income"
                              : "Type: Expense",
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => amountProvider.updateFilters(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (amountProvider.filterDateRange != null) ...[
                      Chip(
                        label: Text(
                          "Date: ${DateFormat('dd/MM').format(amountProvider.filterDateRange!.start)}-${DateFormat('dd/MM').format(amountProvider.filterDateRange!.end)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => amountProvider.updateFilters(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),

          // Transactions list
          Expanded(
            child:
                list.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color:
                                isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No matching transactions found.",
                            style: TextStyle(color: AppColors.textMutedDark),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var amount = list[index];
                        var isExpense = !amount.incomeStatus;
                        var categoryColor = CategoryStyle.getColor(
                          amount.title,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: categoryColor.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                CategoryStyle.getIcon(amount.title),
                                color: categoryColor,
                              ),
                            ),
                            title: Text(
                              amount.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (amount.subtitle.isNotEmpty)
                                  Text(amount.subtitle),
                                Text(
                                  "${amount.dateTime} • ${amount.payMethod}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${isExpense ? '-' : '+'}${currencyProvider.selectedCurrencySymbol}${amount.amount.toStringAsFixed(1)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isExpense
                                            ? AppColors.expense
                                            : AppColors.income,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.expense,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              "Delete Transaction",
                                            ),
                                            content: const Text(
                                              "Are you sure you want to delete this transaction?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  amountProvider.deleteAmount(
                                                    amount,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: AppColors.expense,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
