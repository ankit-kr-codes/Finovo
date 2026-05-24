import 'dart:io';
import 'package:expen/hive/hive_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AmountProvider with ChangeNotifier {
  // Hive Boxes
  final Box<Amount> _box = Hive.box<Amount>('expenses');
  final Box<BudgetLimit> _budgetBox = Hive.box<BudgetLimit>('budgets');
  final Box<SavingsGoal> _goalsBox = Hive.box<SavingsGoal>('goals');
  final Box<RecurringExpense> _recurringBox = Hive.box<RecurringExpense>(
    'recurring',
  );
  final Box<CustomCategory> _categoryBox = Hive.box<CustomCategory>(
    'categories',
  );

  double _range = 2000;
  bool _showDateTime = true;

  // Search & Filter state variables
  String _filterSearchQuery = "";
  String? _filterCategory;
  bool? _filterIsIncome; // null = all, true = income, false = expense
  DateTimeRange? _filterDateRange;
  double? _filterMinAmount;
  double? _filterMaxAmount;

  // Default Categories
  static const List<String> defaultCategories = [
    "Food",
    "Hostel",
    "Transport",
    "Shopping",
    "Recharge",
    "Entertainment",
    "Health",
  ];

  // Constructor
  AmountProvider() {
    _loadRange();
    _loadDateTime();
    processRecurringExpenses(); // Process recurring expenses on startup
  }

  // Getters
  List<Amount> get amounts => _box.values.toList().reversed.toList();
  double get range => _range;
  bool get showDateTime => _showDateTime;

  // Search/Filter Getters & Setters
  String get filterSearchQuery => _filterSearchQuery;
  String? get filterCategory => _filterCategory;
  bool? get filterIsIncome => _filterIsIncome;
  DateTimeRange? get filterDateRange => _filterDateRange;
  double? get filterMinAmount => _filterMinAmount;
  double? get filterMaxAmount => _filterMaxAmount;

  void updateFilters({
    String? searchQuery,
    String? category,
    bool? isIncome,
    DateTimeRange? dateRange,
    double? minAmount,
    double? maxAmount,
  }) {
    if (searchQuery != null) _filterSearchQuery = searchQuery;
    _filterCategory = category;
    _filterIsIncome = isIncome;
    _filterDateRange = dateRange;
    _filterMinAmount = minAmount;
    _filterMaxAmount = maxAmount;
    notifyListeners();
  }

  void clearFilters() {
    _filterSearchQuery = "";
    _filterCategory = null;
    _filterIsIncome = null;
    _filterDateRange = null;
    _filterMinAmount = null;
    _filterMaxAmount = null;
    notifyListeners();
  }

  // Parses Amount dateTime string to DateTime
  DateTime parseDate(String dateStr) {
    try {
      if (dateStr.contains('  ')) {
        return DateFormat('dd MMMM yyyy  hh:mm a').parse(dateStr);
      } else {
        return DateFormat('dd MMMM yyyy').parse(dateStr);
      }
    } catch (e) {
      try {
        return DateFormat('dd MMMM yyyy').parse(dateStr.split('  ').first);
      } catch (ee) {
        return DateTime.now();
      }
    }
  }

  // Get filtered transactions list
  List<Amount> get filteredAmounts {
    return _box.values
        .where((item) {
          // 1. Search Query filter (matches category/title or notes/subtitle)
          if (_filterSearchQuery.isNotEmpty) {
            var query = _filterSearchQuery.toLowerCase();
            var titleMatch = item.title.toLowerCase().contains(query);
            var notesMatch = item.subtitle.toLowerCase().contains(query);
            if (!titleMatch && !notesMatch) return false;
          }

          // 2. Category filter
          if (_filterCategory != null && item.title != _filterCategory) {
            return false;
          }

          // 3. Type filter
          if (_filterIsIncome != null && item.incomeStatus != _filterIsIncome) {
            return false;
          }

          // 4. Date range filter
          if (_filterDateRange != null) {
            var date = parseDate(item.dateTime);
            var start = DateTime(
              _filterDateRange!.start.year,
              _filterDateRange!.start.month,
              _filterDateRange!.start.day,
            );
            var end = DateTime(
              _filterDateRange!.end.year,
              _filterDateRange!.end.month,
              _filterDateRange!.end.day,
              23,
              59,
              59,
            );
            if (date.isBefore(start) || date.isAfter(end)) return false;
          }

          // 5. Min amount filter
          if (_filterMinAmount != null && item.amount < _filterMinAmount!) {
            return false;
          }

          // 6. Max amount filter
          if (_filterMaxAmount != null && item.amount > _filterMaxAmount!) {
            return false;
          }

          return true;
        })
        .toList()
        .reversed
        .toList();
  }

  // Dashboard Stats Getters
  double get totalBalance {
    return _box.values.fold(0.0, (sum, item) {
      if (item.incomeStatus) {
        return sum + item.amount;
      } else {
        return sum - item.amount;
      }
    });
  }

  double get totalAmount => _box.values.fold(
    0.0,
    (sum, item) => sum + (item.incomeStatus ? 0 : item.amount),
  );

  double get monthlySpending {
    var now = DateTime.now();
    return _box.values
        .where((item) {
          if (item.incomeStatus) return false;
          var date = parseDate(item.dateTime);
          return date.month == now.month && date.year == now.year;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get monthlyIncome {
    var now = DateTime.now();
    return _box.values
        .where((item) {
          if (!item.incomeStatus) return false;
          var date = parseDate(item.dateTime);
          return date.month == now.month && date.year == now.year;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get monthlySavings {
    return monthlyIncome - monthlySpending;
  }

  // Transaction CRUD operations
  Future<void> addAmount(
    String title,
    String subtitle,
    double amount,
    DateTime date, {
    bool isIncome = false,
    String paymentMethod = "Cash",
  }) async {
    String formatDateTime(DateTime dateTime) {
      DateTime date1 = DateTime(dateTime.year, dateTime.month, dateTime.day);
      DateTime date2 = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      if (date1.isBefore(date2)) {
        return DateFormat('dd MMMM yyyy').format(dateTime);
      } else {
        return DateFormat('dd MMMM yyyy  hh:mm a').format(dateTime);
      }
    }

    String dateTimeStr = formatDateTime(date);
    var newAmount = Amount(
      title,
      subtitle,
      amount,
      dateTimeStr,
      isIncome: isIncome,
      paymentMethod: paymentMethod,
    );

    await _box.add(newAmount);
    notifyListeners();
  }

  Future<void> deleteAmount(Amount amount) async {
    int correctIndex = _box.values.toList().indexOf(amount);
    if (correctIndex != -1) {
      await _box.deleteAt(correctIndex);
      notifyListeners();
    }
  }

  Future<void> deleteAllExpenses() async {
    await _box.clear();
    notifyListeners();
  }

  // Categories management
  List<String> get allCategories {
    List<String> list = List.from(defaultCategories);
    list.addAll(_categoryBox.values.map((c) => c.name));
    return list;
  }

  Future<void> addCustomCategory(String name) async {
    var cleanName = name.trim();
    if (cleanName.isEmpty) return;
    if (allCategories.any((c) => c.toLowerCase() == cleanName.toLowerCase()))
      return;

    await _categoryBox.add(CustomCategory(cleanName));
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String name) async {
    var index = _categoryBox.values.toList().indexWhere((c) => c.name == name);
    if (index != -1) {
      await _categoryBox.deleteAt(index);
      notifyListeners();
    }
  }

  // Budget Limits management
  List<BudgetLimit> get budgets => _budgetBox.values.toList();

  double getBudgetLimit(String category) {
    var budget = _budgetBox.values.firstWhere(
      (b) => b.category == category,
      orElse: () => BudgetLimit(category, 0.0),
    );
    return budget.limitAmount;
  }

  double getCategoryMonthlySpending(String category) {
    var now = DateTime.now();
    return _box.values
        .where((item) {
          if (item.incomeStatus) return false;
          if (item.title != category) return false;
          var date = parseDate(item.dateTime);
          return date.month == now.month && date.year == now.year;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> setBudget(String category, double limitAmount) async {
    var index = _budgetBox.values.toList().indexWhere(
      (b) => b.category == category,
    );
    if (index != -1) {
      if (limitAmount <= 0) {
        await _budgetBox.deleteAt(index);
      } else {
        await _budgetBox.putAt(index, BudgetLimit(category, limitAmount));
      }
    } else if (limitAmount > 0) {
      await _budgetBox.add(BudgetLimit(category, limitAmount));
    }
    notifyListeners();
  }

  List<String> getBudgetAlerts() {
    List<String> alerts = [];
    for (var b in _budgetBox.values) {
      double spent = getCategoryMonthlySpending(b.category);
      if (b.limitAmount > 0) {
        double ratio = spent / b.limitAmount;
        if (ratio >= 1.0) {
          alerts.add(
            "You have exceeded your limit for ${b.category} (${spent.toStringAsFixed(0)}/${b.limitAmount.toStringAsFixed(0)})!",
          );
        } else if (ratio >= 0.85) {
          alerts.add(
            "You're near your limit for ${b.category} (spent ${spent.toStringAsFixed(0)} of ${b.limitAmount.toStringAsFixed(0)}).",
          );
        }
      }
    }
    return alerts;
  }

  // Savings Goals management
  List<SavingsGoal> get goals => _goalsBox.values.toList();

  Future<void> addSavingsGoal(String title, double targetAmount) async {
    if (title.trim().isEmpty || targetAmount <= 0) return;
    await _goalsBox.add(SavingsGoal(title.trim(), targetAmount, 0.0));
    notifyListeners();
  }

  Future<void> deleteSavingsGoal(SavingsGoal goal) async {
    int index = _goalsBox.values.toList().indexOf(goal);
    if (index != -1) {
      await _goalsBox.deleteAt(index);
      notifyListeners();
    }
  }

  Future<void> depositToGoal(SavingsGoal goal, double amount) async {
    int index = _goalsBox.values.toList().indexOf(goal);
    if (index != -1 && amount > 0) {
      double newSaved = goal.savedAmount + amount;
      await _goalsBox.putAt(
        index,
        SavingsGoal(goal.title, goal.targetAmount, newSaved),
      );
      // Log as special savings transaction (expense so balance reflects saving)
      await addAmount(
        "Savings Goal",
        "Saved towards: ${goal.title}",
        amount,
        DateTime.now(),
        paymentMethod: "Savings",
      );
      notifyListeners();
    }
  }

  Future<void> withdrawFromGoal(SavingsGoal goal, double amount) async {
    int index = _goalsBox.values.toList().indexOf(goal);
    if (index != -1 && amount > 0 && goal.savedAmount >= amount) {
      double newSaved = goal.savedAmount - amount;
      await _goalsBox.putAt(
        index,
        SavingsGoal(goal.title, goal.targetAmount, newSaved),
      );
      // Log as income transaction (adds back to balance)
      await addAmount(
        "Savings Goal",
        "Withdrew from: ${goal.title}",
        amount,
        DateTime.now(),
        isIncome: true,
        paymentMethod: "Savings",
      );
      notifyListeners();
    }
  }

  // Recurring Expenses management
  List<RecurringExpense> get recurringExpenses => _recurringBox.values.toList();

  Future<void> addRecurringExpense(
    String title,
    double amount,
    String category,
    String paymentMethod,
    String interval,
    DateTime firstDueDate, {
    bool isIncome = false,
  }) async {
    if (title.trim().isEmpty || amount <= 0) return;
    String dateStr = DateFormat('yyyy-MM-dd').format(firstDueDate);
    var item = RecurringExpense(
      title.trim(),
      amount,
      category,
      paymentMethod,
      interval,
      dateStr,
      isIncome: isIncome,
    );
    await _recurringBox.add(item);
    notifyListeners();
    await processRecurringExpenses();
  }

  Future<void> deleteRecurringExpense(RecurringExpense item) async {
    int index = _recurringBox.values.toList().indexOf(item);
    if (index != -1) {
      await _recurringBox.deleteAt(index);
      notifyListeners();
    }
  }

  Future<void> processRecurringExpenses() async {
    var today = DateTime.now();
    bool updated = false;

    for (int i = 0; i < _recurringBox.length; i++) {
      var rec = _recurringBox.getAt(i);
      if (rec == null) continue;

      DateTime dueDate;
      try {
        dueDate = DateFormat('yyyy-MM-dd').parse(rec.nextDueDate);
      } catch (e) {
        continue;
      }

      // Check if due date is today or in the past
      while (dueDate.isBefore(today) ||
          (dueDate.year == today.year &&
              dueDate.month == today.month &&
              dueDate.day == today.day)) {
        // Create transaction record
        await addAmount(
          rec.category,
          "[Recurring] ${rec.title}",
          rec.amount,
          dueDate,
          isIncome: rec.incomeStatus,
          paymentMethod: rec.paymentMethod,
        );

        // Advance due date based on interval
        if (rec.interval == "Weekly") {
          dueDate = dueDate.add(const Duration(days: 7));
        } else if (rec.interval == "Monthly") {
          dueDate = DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
        } else if (rec.interval == "Yearly") {
          dueDate = DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
        } else {
          break; // Avoid infinite loop
        }

        updated = true;
      }

      if (updated) {
        String newDateStr = DateFormat('yyyy-MM-dd').format(dueDate);
        await _recurringBox.putAt(
          i,
          RecurringExpense(
            rec.title,
            rec.amount,
            rec.category,
            rec.paymentMethod,
            rec.interval,
            newDateStr,
            isIncome: rec.incomeStatus,
          ),
        );
      }
    }

    if (updated) {
      notifyListeners();
    }
  }

  // Export options
  Future<void> exportToCSV() async {
    var csvRows = [
      ["Date", "Type", "Category", "Amount", "Payment Method", "Notes"],
    ];

    for (var a in amounts) {
      csvRows.add([
        a.dateTime,
        a.incomeStatus ? "Income" : "Expense",
        a.title,
        a.amount.toString(),
        a.payMethod,
        a.subtitle,
      ]);
    }

    String csvContent = csvRows
        .map(
          (row) =>
              row.map((field) => '"${field.replaceAll('"', '""')}"').join(','),
        )
        .join('\n');

    var tempDir = await getTemporaryDirectory();
    var file = File('${tempDir.path}/finovo_transactions_export.csv');
    await file.writeAsString(csvContent);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Finovo Transactions CSV Export");
  }

  Future<void> exportToExcel() async {
    // Generate styled XML spreadsheet content (Excel readable)
    var buffer = StringBuffer();
    buffer.write('<?xml version="1.0"?>\n');
    buffer.write('<?mso-application progid="Excel.Sheet"?>\n');
    buffer.write(
      '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"\n',
    );
    buffer.write(' xmlns:o="urn:schemas-microsoft-com:office:office"\n');
    buffer.write(' xmlns:x="urn:schemas-microsoft-com:office:excel"\n');
    buffer.write(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"\n');
    buffer.write(' xmlns:html="http://www.w3.org/TR/REC-html40">\n');
    buffer.write(' <Worksheet ss:Name="Transactions">\n');
    buffer.write('  <Table>\n');
    buffer.write('   <Row>\n');
    buffer.write('    <Cell><Data ss:Type="String">Date</Data></Cell>\n');
    buffer.write('    <Cell><Data ss:Type="String">Type</Data></Cell>\n');
    buffer.write('    <Cell><Data ss:Type="String">Category</Data></Cell>\n');
    buffer.write('    <Cell><Data ss:Type="String">Amount</Data></Cell>\n');
    buffer.write(
      '    <Cell><Data ss:Type="String">Payment Method</Data></Cell>\n',
    );
    buffer.write('    <Cell><Data ss:Type="String">Notes</Data></Cell>\n');
    buffer.write('   </Row>\n');

    for (var a in amounts) {
      buffer.write('   <Row>\n');
      buffer.write(
        '    <Cell><Data ss:Type="String">${a.dateTime}</Data></Cell>\n',
      );
      buffer.write(
        '    <Cell><Data ss:Type="String">${a.incomeStatus ? "Income" : "Expense"}</Data></Cell>\n',
      );
      buffer.write(
        '    <Cell><Data ss:Type="String">${a.title}</Data></Cell>\n',
      );
      buffer.write(
        '    <Cell><Data ss:Type="Number">${a.amount}</Data></Cell>\n',
      );
      buffer.write(
        '    <Cell><Data ss:Type="String">${a.payMethod}</Data></Cell>\n',
      );
      buffer.write(
        '    <Cell><Data ss:Type="String">${a.subtitle}</Data></Cell>\n',
      );
      buffer.write('   </Row>\n');
    }

    buffer.write('  </Table>\n');
    buffer.write(' </Worksheet>\n');
    buffer.write('</Workbook>\n');

    var tempDir = await getTemporaryDirectory();
    var file = File('${tempDir.path}/finovo_transactions_export.xml');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Finovo Transactions Excel Export");
  }

  Future<void> exportToPDF() async {
    final doc = pw.Document();
    final headerColor = PdfColor.fromHex('#264E46');
    final incomeColor = PdfColor.fromHex('#10B981');
    final expenseColor = PdfColor.fromHex('#EF4444');
    final mutedColor = PdfColor.fromHex('#6B7280');
    final now = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Finovo — Transaction Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: headerColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated on: ${DateFormat('dd MMMM yyyy  hh:mm a').format(now)}',
              style: pw.TextStyle(fontSize: 10, color: mutedColor),
            ),
            pw.Divider(color: headerColor, thickness: 1.5),
            pw.SizedBox(height: 8),
            // Summary row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _pdfSummaryBox('Total Balance', totalBalance, headerColor),
                _pdfSummaryBox('Monthly Income', monthlyIncome, incomeColor),
                _pdfSummaryBox('Monthly Spending', monthlySpending, expenseColor),
              ],
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#E2E8F0'),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(2.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerColor),
                children: [
                  _pdfCell('Date', isHeader: true),
                  _pdfCell('Type', isHeader: true),
                  _pdfCell('Category', isHeader: true),
                  _pdfCell('Amount', isHeader: true),
                  _pdfCell('Method', isHeader: true),
                  _pdfCell('Notes', isHeader: true),
                ],
              ),
              // Data rows
              ...amounts.asMap().entries.map((entry) {
                final idx = entry.key;
                final a = entry.value;
                final rowColor = idx.isEven
                    ? PdfColor.fromHex('#F7F5F2')
                    : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: rowColor),
                  children: [
                    _pdfCell(a.dateTime),
                    _pdfCell(
                      a.incomeStatus ? 'Income' : 'Expense',
                      textColor: a.incomeStatus ? incomeColor : expenseColor,
                    ),
                    _pdfCell(a.title),
                    _pdfCell(a.amount.toStringAsFixed(2)),
                    _pdfCell(a.payMethod),
                    _pdfCell(a.subtitle),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/finovo_report.pdf');
    await file.writeAsBytes(await doc.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Finovo Financial Report',
    );
  }

  pw.Widget _pdfCell(
    String text, {
    bool isHeader = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : (textColor ?? PdfColors.black),
        ),
      ),
    );
  }

  pw.Widget _pdfSummaryBox(String label, double value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.7), fontSize: 9),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value.toStringAsFixed(2),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Load target & options
  Future<void> showDateTimeFunction(bool newDateTime) async {
    _showDateTime = newDateTime;
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('showDateTime', newDateTime);
    notifyListeners();
  }

  Future<void> _loadDateTime() async {
    var pref = await SharedPreferences.getInstance();
    _showDateTime = pref.getBool('showDateTime') ?? true;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> setRange(double newRange) async {
    _range = newRange;
    var prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('targetLimit', newRange);
    notifyListeners();
  }

  Future<void> _loadRange() async {
    var prefs = await SharedPreferences.getInstance();
    _range = prefs.getDouble('targetLimit') ?? 2000;
    Future.delayed(Duration.zero, () => notifyListeners());
  }
}
