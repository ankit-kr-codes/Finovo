import 'dart:math';
import 'package:expen/core/theme.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/hive/hive_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  int _activeTab =
      0; // 0 = Categories (Pie), 1 = Trend (Line), 2 = Weekly (Bar)

  @override
  Widget build(BuildContext context) {
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String currencySymbol = currencyProvider.selectedCurrencySymbol;
    var isDark = Theme.of(context).brightness == Brightness.dark;

    // Expenses only
    var expenses =
        amountProvider.amounts.where((a) => !a.incomeStatus).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Selector Tab Buttons
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
                    _chartTabButton(0, "Categories", _activeTab == 0),
                    _chartTabButton(1, "Trend", _activeTab == 1),
                    _chartTabButton(2, "Weekly", _activeTab == 2),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Empty State
              if (expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 64,
                          color:
                              isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No expense data available for charts.",
                          style: TextStyle(color: AppColors.textMutedDark),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // 2. Chart Viewer Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: premiumCardDeco(isDark: isDark),
                  child: SizedBox(
                    height: 280,
                    child: _buildActiveChart(expenses, amountProvider, isDark),
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Details Panel
                if (_activeTab == 0) ...[
                  const Text(
                    "Category Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryDetails(expenses, currencySymbol, isDark),
                ] else if (_activeTab == 1) ...[
                  const Text(
                    "Monthly Spendings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTrendDetails(
                    expenses,
                    currencySymbol,
                    isDark,
                    amountProvider,
                  ),
                ] else ...[
                  const Text(
                    "Weekly Spendings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyDetails(
                    expenses,
                    currencySymbol,
                    isDark,
                    amountProvider,
                  ),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartTabButton(int index, String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : null,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChart(
    List<Amount> expenses,
    AmountProvider provider,
    bool isDark,
  ) {
    if (_activeTab == 0) {
      return _buildPieChart(expenses);
    } else if (_activeTab == 1) {
      return _buildLineChart(expenses, provider, isDark);
    } else {
      return _buildBarChart(expenses, provider);
    }
  }

  // 1. PIE CHART: Category Breakdown
  Widget _buildPieChart(List<Amount> expenses) {
    Map<String, double> categorySums = {};
    double total = 0;
    for (var e in expenses) {
      categorySums[e.title] = (categorySums[e.title] ?? 0.0) + e.amount;
      total += e.amount;
    }

    int colorIndex = 0;
    List<PieChartSectionData> sections =
        categorySums.entries.map((entry) {
          var percentage = (entry.value / total) * 100;
          var color = CategoryStyle.getColor(entry.key);
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return PieChart(
      PieChartData(sectionsSpace: 2, centerSpaceRadius: 55, sections: sections),
    );
  }

  // 2. LINE CHART: Monthly Trend Graph
  Widget _buildLineChart(
    List<Amount> expenses,
    AmountProvider provider,
    bool isDark,
  ) {
    // Group expenses by Month (e.g. "Jan", "Feb")
    Map<String, double> monthlyData = {};
    DateFormat formatter = DateFormat('MMM');

    // Get last 6 months list dynamically
    List<DateTime> months =
        List.generate(6, (i) {
          var now = DateTime.now();
          return DateTime(now.year, now.month - i);
        }).reversed.toList();

    for (var m in months) {
      monthlyData[formatter.format(m)] = 0.0;
    }

    for (var e in expenses) {
      var dt = provider.parseDate(e.dateTime);
      var key = formatter.format(dt);
      if (monthlyData.containsKey(key)) {
        monthlyData[key] = (monthlyData[key] ?? 0.0) + e.amount;
      }
    }

    List<FlSpot> spots = [];
    int idx = 0;
    double maxVal = 100;
    for (var m in months) {
      var key = formatter.format(m);
      var val = monthlyData[key] ?? 0.0;
      spots.add(FlSpot(idx.toDouble(), val));
      if (val > maxVal) maxVal = val;
      idx++;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        maxY: maxVal * 1.15,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= 0 && val.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      formatter.format(months[val.toInt()]),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  // 3. BAR CHART: Weekly spending (Mon - Sun)
  Widget _buildBarChart(List<Amount> expenses, AmountProvider provider) {
    // Find expenses for current week
    var today = DateTime.now();
    var startOfWeek = today.subtract(
      Duration(days: today.weekday - 1),
    ); // Monday
    Map<int, double> dailySums = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
    }; // Mon-Sun

    for (var e in expenses) {
      var date = provider.parseDate(e.dateTime);
      var diff = date.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7 && date.year == today.year) {
        dailySums[date.weekday] = (dailySums[date.weekday] ?? 0.0) + e.amount;
      }
    }

    double maxVal = 100;
    List<BarChartGroupData> barGroups =
        dailySums.entries.map((entry) {
          var val = entry.value;
          if (val > maxVal) maxVal = val;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: val,
                color: AppColors.primary,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

    List<String> weekdays = [
      "",
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        maxY: maxVal * 1.15,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                var day = val.toInt();
                if (day >= 1 && day <= 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weekdays[day],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  // 4. Details List Generators
  Widget _buildCategoryDetails(
    List<Amount> expenses,
    String currencySymbol,
    bool isDark,
  ) {
    Map<String, double> categorySums = {};
    double total = 0;
    for (var e in expenses) {
      categorySums[e.title] = (categorySums[e.title] ?? 0.0) + e.amount;
      total += e.amount;
    }

    var list =
        categorySums.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children:
          list.map((entry) {
            var percentage = (entry.value / total) * 100;
            var color = CategoryStyle.getColor(entry.key);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.circle, color: color, size: 12),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$currencySymbol${entry.value.toStringAsFixed(1)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTrendDetails(
    List<Amount> expenses,
    String currencySymbol,
    bool isDark,
    AmountProvider provider,
  ) {
    Map<String, double> monthlyData = {};
    DateFormat formatter = DateFormat('MMMM yyyy');

    for (var e in expenses) {
      var dt = provider.parseDate(e.dateTime);
      var key = formatter.format(dt);
      monthlyData[key] = (monthlyData[key] ?? 0.0) + e.amount;
    }

    var list =
        monthlyData.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    return Column(
      children:
          list.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  "$currencySymbol${entry.value.toStringAsFixed(1)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.expense,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildWeeklyDetails(
    List<Amount> expenses,
    String currencySymbol,
    bool isDark,
    AmountProvider provider,
  ) {
    var today = DateTime.now();
    var startOfWeek = today.subtract(
      Duration(days: today.weekday - 1),
    ); // Monday
    Map<int, double> dailySums = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var e in expenses) {
      var date = provider.parseDate(e.dateTime);
      var diff = date.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7 && date.year == today.year) {
        dailySums[date.weekday] = (dailySums[date.weekday] ?? 0.0) + e.amount;
      }
    }

    List<String> weekdays = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return Column(
      children:
          dailySums.entries.map((entry) {
            var date = startOfWeek.add(Duration(days: entry.key - 1));
            var dateStr = DateFormat('dd MMM').format(date);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  weekdays[entry.key],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(dateStr, style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  "$currencySymbol${entry.value.toStringAsFixed(1)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
    );
  }
}
