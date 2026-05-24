import 'package:expen/core/theme.dart';
import 'package:expen/core/currency_symbol.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/pages/nav_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Computes today's spending
  double _todaySpending(AmountProvider p) {
    final today = DateTime.now();
    return p.amounts
        .where((a) {
          if (a.incomeStatus) return false;
          final d = p.parseDate(a.dateTime);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        })
        .fold(0.0, (s, a) => s + a.amount);
  }

  // Computes days remaining in month
  int _daysLeft() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day + 1;
  }

  @override
  Widget build(BuildContext context) {
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String cs = currencyProvider.selectedCurrencySymbol;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    var alerts = amountProvider.getBudgetAlerts();

    // Spending health metrics
    final double monthlyIncome = amountProvider.monthlyIncome;
    final double monthlySpending = amountProvider.monthlySpending;
    final double spendingRatio =
        monthlyIncome > 0 ? (monthlySpending / monthlyIncome).clamp(0.0, 1.0) : 0;
    final Color healthColor = spendingRatio < 0.6
        ? AppColors.healthGood
        : (spendingRatio < 0.85 ? AppColors.healthFair : AppColors.healthBad);
    final String healthLabel = spendingRatio < 0.6
        ? "Healthy"
        : (spendingRatio < 0.85 ? "Watch Out" : "Overspending");
    final IconData healthIcon = spendingRatio < 0.6
        ? Icons.check_circle_rounded
        : (spendingRatio < 0.85 ? Icons.warning_rounded : Icons.dangerous_rounded);

    // Daily safe-to-spend
    final int daysLeft = _daysLeft();
    final double safeToSpend = monthlyIncome > 0
        ? ((monthlyIncome - monthlySpending) / daysLeft).clamp(0, double.infinity)
        : 0;
    final double todaySpent = _todaySpending(amountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finovo"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Glassmorphic Total Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: glassmorphicDeco(
                  isDark: isDark,
                  gradient: isDark
                      ? AppColors.balanceGradientDark
                      : AppColors.balanceGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL BALANCE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$cs${amountProvider.totalBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _balanceChip(
                          icon: Icons.arrow_downward,
                          label: "Income",
                          value: "$cs${amountProvider.monthlyIncome.toStringAsFixed(0)}",
                          color: Colors.greenAccent,
                        ),
                        _balanceChip(
                          icon: Icons.arrow_upward,
                          label: "Expenses",
                          value: "$cs${amountProvider.monthlySpending.toStringAsFixed(0)}",
                          color: Colors.redAccent.shade100,
                        ),
                        _balanceChip(
                          icon: Icons.savings_outlined,
                          label: "Saved",
                          value: "$cs${amountProvider.monthlySavings.toStringAsFixed(0)}",
                          color: Colors.cyanAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Spending Health + Daily Budget card
              if (monthlyIncome > 0)
                _buildSpendingHealthCard(
                  isDark: isDark,
                  cs: cs,
                  spendingRatio: spendingRatio,
                  healthColor: healthColor,
                  healthLabel: healthLabel,
                  healthIcon: healthIcon,
                  safeToSpend: safeToSpend,
                  todaySpent: todaySpent,
                  daysLeft: daysLeft,
                ),
              if (monthlyIncome > 0) const SizedBox(height: 16),

              // 3. Budget Limits Warn Alert Banner
              if (alerts.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(
                      alpha: isDark ? 0.15 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          alerts.first,
                          style: TextStyle(
                            color:
                                isDark ? Colors.amber[200] : Colors.amber[900],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Savings Goals Horizontal Carousel
              if (amountProvider.goals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Savings Goals",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          navLayoutKey.currentState?.switchToTab(3),
                      child: const Text("Manage"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: amountProvider.goals.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var goal = amountProvider.goals[index];
                      var progress = (goal.savedAmount / goal.targetAmount)
                          .clamp(0.0, 1.0);
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: premiumCardDeco(isDark: isDark),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              goal.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$cs${goal.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedLight
                                    : AppColors.textMutedDark,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                    isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? AppColors.primaryDark
                                      : AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Quick Actions
              const Text(
                "Quick Add",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/addexpense'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: premiumCardDeco(isDark: isDark),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.expense,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "New Expense",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/addexpense?income=true'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: premiumCardDeco(isDark: isDark),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.income,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "New Income",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (amountProvider.amounts.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Switch to History tab (index 1)
                        navLayoutKey.currentState?.switchToTab(1);
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (amountProvider.amounts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color:
                              isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No transactions recorded yet.\nTap '+' to add your first one.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedLight
                                : AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      amountProvider.amounts.length > 5
                          ? 5
                          : amountProvider.amounts.length,
                  itemBuilder: (context, index) {
                    var amount = amountProvider.amounts[index];
                    var isExpense = !amount.incomeStatus;
                    var categoryColor = CategoryStyle.getColor(amount.title);

                    return Dismissible(
                      key: Key(amount.key.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(
                          color: AppColors.expense,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.textLight,
                        ),
                      ),
                      onDismissed: (direction) {
                        amountProvider.deleteAmount(amount);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction deleted')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
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
                            amount.title.isEmpty ? "Other" : amount.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            amount.subtitle.isEmpty
                                ? amount.dateTime
                                : amount.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedLight
                                  : AppColors.textMutedDark,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${isExpense ? '-' : '+'}$cs${amount.amount.toStringAsFixed(1)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isExpense
                                          ? AppColors.expense
                                          : AppColors.income,
                                  fontSize: 15,
                                ),
                              ),
                              if (amountProvider.showDateTime &&
                                  amount.subtitle.isNotEmpty)
                                Text(
                                  amount.dateTime,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.textMutedLight
                                        : AppColors.textMutedDark,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          radius: 14,
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpendingHealthCard({
    required bool isDark,
    required String cs,
    required double spendingRatio,
    required Color healthColor,
    required String healthLabel,
    required IconData healthIcon,
    required double safeToSpend,
    required double todaySpent,
    required int daysLeft,
  }) {
    final today = DateFormat('MMMM d').format(DateTime.now());
    final todayIsOver = todaySpent > safeToSpend && safeToSpend > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: healthColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: healthColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(healthIcon, color: healthColor, size: 18),
              const SizedBox(width: 8),
              Text(
                "Spending Health · $healthLabel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: healthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: spendingRatio,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(spendingRatio * 100).toStringAsFixed(1)}% of income spent this month",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
            ),
          ),
          const Divider(height: 20),
          // Daily budget row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dailyStat(
                isDark: isDark,
                label: "Today ($today)",
                value: "$cs${todaySpent.toStringAsFixed(0)}",
                sub: todayIsOver ? "Over budget!" : "Spent today",
                valueColor: todayIsOver ? AppColors.expense : null,
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              _dailyStat(
                isDark: isDark,
                label: "Safe to spend/day",
                value: "$cs${safeToSpend.toStringAsFixed(0)}",
                sub: "$daysLeft days left",
                valueColor: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dailyStat({
    required bool isDark,
    required String label,
    required String value,
    required String sub,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: valueColor,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: valueColor ??
                  (isDark ? AppColors.textMutedLight : AppColors.textMutedDark),
            ),
          ),
        ],
      ),
    );
  }
}
