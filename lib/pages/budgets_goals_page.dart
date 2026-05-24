import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/core/theme.dart';
import 'package:expen/hive/hive_database.dart';

class BudgetsGoalsPage extends StatefulWidget {
  const BudgetsGoalsPage({super.key});

  @override
  State<BudgetsGoalsPage> createState() => _BudgetsGoalsPageState();
}

class _BudgetsGoalsPageState extends State<BudgetsGoalsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddBudgetDialog(BuildContext context, AmountProvider provider) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedCat = provider.allCategories.first;
    var limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.darkCard : AppColors.lightCard,
              title: const Text("Set Category Budget"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedCat,
                    isExpanded: true,
                    items:
                        provider.allCategories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                    onChanged: (val) => setStateDialog(() => selectedCat = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter budget limit",
                      labelText: "Limit Amount",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    double? val = double.tryParse(limitController.text);
                    if (val != null && val > 0 && selectedCat != null) {
                      provider.setBudget(selectedCat!, val);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Set"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context, AmountProvider provider) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var titleController = TextEditingController();
    var targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: const Text("Add Savings Goal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "e.g. Headphones, Laptop, Trip",
                  labelText: "Goal Name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter target amount",
                  labelText: "Target Amount",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double? target = double.tryParse(targetController.text);
                var title = titleController.text.trim();
                if (title.isNotEmpty && target != null && target > 0) {
                  provider.addSavingsGoal(title, target);
                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _showDepositWithdrawDialog(
    BuildContext context,
    AmountProvider provider,
    SavingsGoal goal,
    bool isDeposit,
  ) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Text(isDeposit ? "Deposit Funds" : "Withdraw Funds"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDeposit
                    ? "Transfer funds to savings for: ${goal.title}"
                    : "Transfer savings back to main balance from: ${goal.title}",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMutedDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter transfer amount",
                  labelText: "Amount",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double? val = double.tryParse(amountController.text);
                if (val != null && val > 0) {
                  if (isDeposit) {
                    provider.depositToGoal(goal, val);
                  } else {
                    if (val > goal.savedAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Cannot withdraw more than saved amount!",
                          ),
                        ),
                      );
                      return;
                    }
                    provider.withdrawFromGoal(goal, val);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("Transfer"),
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets & Savings"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "Budgets"), Tab(text: "Savings Goals")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Budgets Tab
          _buildBudgetsTab(context, amountProvider, currencySymbol, isDark),

          // 2. Savings Goals Tab
          _buildGoalsTab(context, amountProvider, currencySymbol, isDark),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab(
    BuildContext context,
    AmountProvider provider,
    String currencySymbol,
    bool isDark,
  ) {
    var list = provider.budgets;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Category Limits",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddBudgetDialog(context, provider),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Set Limit"),
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
        const SizedBox(height: 20),
        if (list.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 48,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No monthly limits set.",
                    style: TextStyle(color: AppColors.textMutedDark),
                  ),
                ],
              ),
            ),
          )
        else
          ...list.map((b) {
            var spent = provider.getCategoryMonthlySpending(b.category);
            var progress = (spent / b.limitAmount).clamp(0.0, 1.0);
            var isOver = spent >= b.limitAmount;
            var isNear = spent >= b.limitAmount * 0.85;

            var progressColor =
                isOver
                    ? AppColors.expense
                    : (isNear ? AppColors.warning : AppColors.primary);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.expense,
                            size: 20,
                          ),
                          onPressed: () => provider.setBudget(b.category, 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Spent: $currencySymbol${spent.toStringAsFixed(0)} / $currencySymbol${b.limitAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        if (isOver)
                          const Text(
                            "Exceeded!",
                            style: TextStyle(
                              color: AppColors.expense,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )
                        else if (isNear)
                          const Text(
                            "Near Limit!",
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGoalsTab(
    BuildContext context,
    AmountProvider provider,
    String currencySymbol,
    bool isDark,
  ) {
    var list = provider.goals;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Savings Targets",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddGoalDialog(context, provider),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("New Goal"),
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
        const SizedBox(height: 20),
        if (list.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 48,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No active savings goals.",
                    style: TextStyle(color: AppColors.textMutedDark),
                  ),
                ],
              ),
            ),
          )
        else
          ...list.map((goal) {
            var progress = (goal.savedAmount / goal.targetAmount).clamp(
              0.0,
              1.0,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Circular Progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 55,
                              height: 55,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor:
                                    isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                              ),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Title & Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Saved: $currencySymbol${goal.savedAmount.toStringAsFixed(0)} of $currencySymbol${goal.targetAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMutedDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Delete
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.expense,
                            size: 20,
                          ),
                          onPressed: () => provider.deleteSavingsGoal(goal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.expense,
                              side: const BorderSide(color: AppColors.expense),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.remove, size: 16),
                            label: const Text("Withdraw"),
                            onPressed:
                                () => _showDepositWithdrawDialog(
                                  context,
                                  provider,
                                  goal,
                                  false,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.income,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Deposit"),
                            onPressed:
                                () => _showDepositWithdrawDialog(
                                  context,
                                  provider,
                                  goal,
                                  true,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
