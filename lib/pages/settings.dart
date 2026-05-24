import 'package:expen/core/theme.dart';
import 'package:expen/core/currency_symbol.dart';
import 'package:expen/hive/hive_database.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/provider/theme_provider.dart';
import 'package:expen/services/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController rangeController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final SmsService _smsService = SmsService();
  bool _smsEnabled = false;
  bool _smsScanning = false;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadSmsToggle();
  }

  Future<void> _loadSmsToggle() async {
    var enabled = await _smsService.isEnabled();
    if (mounted) setState(() => _smsEnabled = enabled);
  }

  Future<void> _toggleSms(bool val) async {
    if (val) {
      var granted = await _smsService.requestSmsPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'SMS permission denied. Please allow in App Settings.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    await _smsService.setEnabled(val);
    if (mounted) setState(() => _smsEnabled = val);
  }

  Future<void> _scanNow() async {
    setState(() => _smsScanning = true);
    var count = await _smsService.scanInbox();
    if (mounted) {
      setState(() => _smsScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? '$count new transaction(s) detected from SMS'
                : 'No new bank transactions found in SMS',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: count > 0 ? AppColors.income : null,
        ),
      );
    }
  }

  void _showCustomCategoryDialog(
    BuildContext context,
    AmountProvider provider,
  ) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            var customCats =
                provider.allCategories
                    .where((c) => !AmountProvider.defaultCategories.contains(c))
                    .toList();
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.darkCard : AppColors.lightCard,
              title: const Text("Manage Custom Categories"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              hintText: "Add category name",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: () {
                            var name = categoryController.text.trim();
                            if (name.isNotEmpty) {
                              provider.addCustomCategory(name);
                              categoryController.clear();
                              setStateDialog(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (customCats.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No custom categories added.",
                          style: TextStyle(
                            color: AppColors.textMutedDark,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: customCats.length,
                            itemBuilder: (context, index) {
                              var cat = customCats[index];
                              return ListTile(
                                dense: true,
                                title: Text(cat),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.expense,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    provider.deleteCustomCategory(cat);
                                    setStateDialog(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
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
    var rangeProvider = Provider.of<AmountProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    var isDark = Theme.of(context).brightness == Brightness.dark;
    this.isDark = isDark;

    AppTheme currentTheme = AppTheme.values.firstWhere(
      (theme) =>
          themeProvider.themeMode == ThemeMode.system &&
              theme == AppTheme.system ||
          themeProvider.themeMode == ThemeMode.light &&
              theme == AppTheme.light ||
          themeProvider.themeMode == ThemeMode.dark && theme == AppTheme.dark,
      orElse: () => AppTheme.system,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 15),

            // Section: Preferences
            _sectionHeader("PREFERENCES"),
            _settingsCard(
              children: [
                _settingsListTile(
                  title: "Currency",
                  subtitle:
                      "${currencySymbol[currencyProvider.selectedCurrencyIndex]["name"]} (${currencyProvider.selectedCurrencySymbol})",
                  icon: Icons.monetization_on_outlined,
                  onTap: () => picker(context),
                ),
                const Divider(indent: 50, height: 1),
                _settingsListTile(
                  title: "App Theme",
                  subtitle:
                      currentTheme == AppTheme.system
                          ? "System"
                          : (currentTheme == AppTheme.light ? "Light" : "Dark"),
                  icon: Icons.dark_mode_outlined,
                  onTap: () {
                    // Open dialog to select Theme
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor:
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                          title: const Text("Select Theme"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("System Default"),
                                leading: const Icon(
                                  Icons.settings_brightness_outlined,
                                ),
                                onTap: () {
                                  themeProvider.setTheme(AppTheme.system);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Light"),
                                leading: const Icon(Icons.wb_sunny_outlined),
                                onTap: () {
                                  themeProvider.setTheme(AppTheme.light);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Dark"),
                                leading: const Icon(Icons.nights_stay_outlined),
                                onTap: () {
                                  themeProvider.setTheme(AppTheme.dark);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(indent: 50, height: 1),
                _settingsSwitchTile(
                  title: "Show Transaction Time",
                  value: rangeProvider.showDateTime,
                  icon: Icons.access_time_outlined,
                  onChanged: (val) => rangeProvider.showDateTimeFunction(val),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Budgets and Categories
            _sectionHeader("BUDGETS & CATEGORIES"),
            _settingsCard(
              children: [
                _settingsListTile(
                  title: "Global Target Limit",
                  subtitle:
                      "${currencyProvider.selectedCurrencySymbol}${rangeProvider.range.toStringAsFixed(0)}",
                  icon: Icons.track_changes_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor:
                                isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                            title: const Text('Set Global Spending Target'),
                            content: TextField(
                              controller: rangeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Enter your target",
                                prefixText:
                                    currencyProvider.selectedCurrencySymbol,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (rangeController.text.isNotEmpty) {
                                    double limit = double.parse(
                                      rangeController.text,
                                    );
                                    rangeProvider.setRange(limit);
                                    rangeController.clear();
                                  }
                                  context.pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
                const Divider(indent: 50, height: 1),
                _settingsListTile(
                  title: "Manage Custom Categories",
                  subtitle: "Create or delete custom spending categories",
                  icon: Icons.grid_view_rounded,
                  onTap:
                      () => _showCustomCategoryDialog(context, rangeProvider),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Backup and Export
            _sectionHeader("BACKUP & EXPORTS"),
            _settingsCard(
              children: [
                _settingsListTile(
                  title: "Export as CSV",
                  subtitle: "Download raw transactions table data",
                  icon: Icons.table_view_outlined,
                  onTap: () => rangeProvider.exportToCSV(),
                ),
                const Divider(indent: 50, height: 1),
                _settingsListTile(
                  title: "Export as Excel",
                  subtitle: "Download spreadsheet compatible sheet file",
                  icon: Icons.description_outlined,
                  onTap: () => rangeProvider.exportToExcel(),
                ),
                const Divider(indent: 50, height: 1),
                _settingsListTile(
                  title: "Export as PDF Report",
                  subtitle:
                      "Generate clean printable financial PDF document",
                  icon: Icons.picture_as_pdf_outlined,
                  onTap: () => rangeProvider.exportToPDF(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: SMS Auto-Detect
            _sectionHeader("SMS AUTO-DETECT"),
            _settingsCard(
              children: [
                // Enable / Disable toggle
                ListTile(
                  leading: Icon(
                    Icons.sms_outlined,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  title: const Text(
                    'Auto-Detect Transactions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Tap "Scan Now" to manually read bank SMS and log expenses',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                    ),
                  ),
                  trailing: Switch(value: _smsEnabled, onChanged: _toggleSms),
                ),
                const Divider(indent: 50, height: 1),

                // Pending count + review link
                ValueListenableBuilder(
                  valueListenable:
                      Hive.box<PendingTransaction>('sms_pending').listenable(),
                  builder: (ctx, Box<PendingTransaction> box, _) {
                    var count = box.length;
                    return ListTile(
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                          if (count > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.expense,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: const Text(
                        'Review Pending Transactions',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        count > 0
                            ? '$count transaction(s) awaiting category'
                            : 'No pending transactions',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              count > 0
                                  ? AppColors.warning
                                  : (isDark ? AppColors.textMutedLight : AppColors.textMutedDark),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                      ),
                      onTap: () => context.push('/sms-review'),
                    );
                  },
                ),
                const Divider(indent: 50, height: 1),

                // Scan now button
                ListTile(
                  leading:
                      _smsScanning
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppColors.primaryDark : AppColors.primary,
                            ),
                          )
                          : Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                  title: const Text(
                    'Scan SMS Inbox Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Manually check inbox for new bank SMS',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                  ),
                  onTap: _smsEnabled ? _scanNow : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Info and Danger
            _sectionHeader("APPLICATION INFO"),
            _settingsCard(
              children: [
                ListTile(
                  onTap: () => context.push('/about'),
                  title: const Text(
                    "About Finovo",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
                  ),
                ),
                const Divider(indent: 50, height: 1),
                ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Reset Finovo Data"),
                            content: const Text(
                              "This action will erase ALL transactions, goals, budgets, and recurring events forever. Are you sure?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  rangeProvider.deleteAllExpenses();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "All data erased successfully.",
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Erase All",
                                  style: TextStyle(color: AppColors.expense),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  title: const Text(
                    "Reset All Data",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.expense,
                    ),
                  ),
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
        ),
      ),
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
      ),
    );
  }

  Widget _settingsSwitchTile({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Future<String?> picker(BuildContext context) {
    return showMaterialScrollPicker<String>(
      context: context,
      title: 'Select Your Currency',
      items:
          currencySymbol.map((e) => '${e["name"]} (${e["symbol"]})').toList(),
      selectedItem:
          currencySymbol[context
              .read<CurrencyProvider>()
              .selectedCurrencyIndex]["name"]!,
      onChanged: (value) {
        var newIndex = currencySymbol.indexWhere(
          (e) => '${e["name"]} (${e["symbol"]})' == value,
        );
        if (newIndex != -1) {
          context.read<CurrencyProvider>().selectCurrency(newIndex);
        }
      },
    );
  }
}
