import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/core/theme.dart';
import 'package:intl/intl.dart';

class RecurringPage extends StatelessWidget {
  const RecurringPage({super.key});

  void _showAddSubscriptionDialog(
    BuildContext context,
    AmountProvider provider,
  ) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var titleController = TextEditingController();
    var amountController = TextEditingController();
    String category = provider.allCategories.first;
    String paymentMethod = "Card";
    String interval = "Monthly";
    DateTime selectedDate = DateTime.now();
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.darkCard : AppColors.lightCard,
              title: const Text("Add Recurring Entry"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type selector
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Expense"),
                            selected: !isIncome,
                            onSelected: (val) {
                              if (val) setStateDialog(() => isIncome = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Income"),
                            selected: isIncome,
                            onSelected: (val) {
                              if (val) setStateDialog(() => isIncome = true);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "e.g. Netflix, Gym, Rent",
                        labelText: "Title",
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter amount",
                        labelText: "Amount",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: "Category"),
                      items:
                          provider.allCategories.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Payment Method
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                      ),
                      items: const [
                        DropdownMenuItem(value: "Cash", child: Text("Cash")),
                        DropdownMenuItem(value: "Card", child: Text("Card")),
                        DropdownMenuItem(value: "UPI", child: Text("UPI")),
                        DropdownMenuItem(
                          value: "Net Banking",
                          child: Text("Net Banking"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null)
                          setStateDialog(() => paymentMethod = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Interval
                    DropdownButtonFormField<String>(
                      initialValue: interval,
                      decoration: const InputDecoration(
                        labelText: "Billing Interval",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Weekly",
                          child: Text("Weekly"),
                        ),
                        DropdownMenuItem(
                          value: "Monthly",
                          child: Text("Monthly"),
                        ),
                        DropdownMenuItem(
                          value: "Yearly",
                          child: Text("Yearly"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => interval = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Next Due Date
                    InkWell(
                      onTap: () async {
                        var picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setStateDialog(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderLight.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Next Due Date:",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    double? amount = double.tryParse(amountController.text);
                    var title = titleController.text.trim();
                    if (title.isNotEmpty && amount != null && amount > 0) {
                      provider.addRecurringExpense(
                        title,
                        amount,
                        category,
                        paymentMethod,
                        interval,
                        selectedDate,
                        isIncome: isIncome,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String currencySymbol = currencyProvider.selectedCurrencySymbol;
    var isDark = Theme.of(context).brightness == Brightness.dark;

    var list = amountProvider.recurringExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text("Subscriptions")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recurring Payments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed:
                      () => _showAddSubscriptionDialog(context, amountProvider),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Finovo will automatically log these transactions when their due dates arrive.",
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  list.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 48,
                              color:
                                  isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No recurring items logged.",
                              style: TextStyle(color: AppColors.textMutedDark),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          var item = list[index];
                          var isExpense = !item.incomeStatus;
                          String formattedDueDate;
                          try {
                            var parsed = DateFormat(
                              'yyyy-MM-dd',
                            ).parse(item.nextDueDate);
                            formattedDueDate = DateFormat(
                              'dd MMM yyyy',
                            ).format(parsed);
                          } catch (e) {
                            formattedDueDate = item.nextDueDate;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isExpense
                                        ? AppColors.expense
                                        : AppColors.income)
                                    .withValues(alpha: 0.15),
                                child: Icon(
                                  isExpense
                                      ? Icons.payment_rounded
                                      : Icons.account_balance_wallet_rounded,
                                  color:
                                      isExpense
                                          ? AppColors.expense
                                          : AppColors.income,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Next Payment: $formattedDueDate (${item.interval})",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMutedDark,
                                    ),
                                  ),
                                  Text(
                                    "Method: ${item.paymentMethod} • Category: ${item.category}",
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
                                    "${isExpense ? '-' : '+'}$currencySymbol${item.amount.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isExpense
                                              ? AppColors.expense
                                              : AppColors.income,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.expense,
                                      size: 20,
                                    ),
                                    onPressed:
                                        () => amountProvider
                                            .deleteRecurringExpense(item),
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
      ),
    );
  }
}
