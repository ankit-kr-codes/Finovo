import 'dart:ui';
import 'package:expen/core/theme.dart';
import 'package:expen/hive/hive_database.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/services/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Screen showing all SMS-detected transactions pending user categorization.
class SmsReviewPage extends StatefulWidget {
  const SmsReviewPage({super.key});

  @override
  State<SmsReviewPage> createState() => _SmsReviewPageState();
}

class _SmsReviewPageState extends State<SmsReviewPage>
    with TickerProviderStateMixin {
  final SmsService _smsService = SmsService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_smsService.getPendingTransactions().isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Dismiss All'),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              onPressed: () => _confirmDismissAll(context),
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<PendingTransaction>('sms_pending').listenable(),
        builder: (context, Box<PendingTransaction> box, _) {
          var pending = box.values.toList().reversed.toList();

          if (pending.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              return _PendingCard(
                key: ValueKey(pending[index].detectedAtMs),
                pending: pending[index],
                isDark: isDark,
                pulseController: _pulseController,
                onApprove:
                    (category, notes) =>
                        _approve(context, pending[index], category, notes),
                onDismiss: () => _dismiss(pending[index]),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    PendingTransaction pending,
    String category,
    String notes,
  ) async {
    var expenseBox = Hive.box<Amount>('expenses');
    await _smsService.approvePending(pending, category, notes, expenseBox);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Added ₹${pending.amount.toStringAsFixed(2)} to $category',
          ),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _dismiss(PendingTransaction pending) async {
    await _smsService.dismissPending(pending);
  }

  Future<void> _confirmDismissAll(BuildContext context) async {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            title: const Text('Dismiss All?'),
            content: const Text(
              'All pending SMS transactions will be removed without saving.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Dismiss All',
                  style: TextStyle(color: AppColors.expense),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) await _smsService.dismissAll();
  }
}

// ─── Empty state widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sms_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Pending Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Bank SMS transactions will appear\nhere for you to categorize.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual pending transaction card ──────────────────────────────────────
class _PendingCard extends StatefulWidget {
  final PendingTransaction pending;
  final bool isDark;
  final AnimationController pulseController;
  final Future<void> Function(String category, String notes) onApprove;
  final VoidCallback onDismiss;

  const _PendingCard({
    super.key,
    required this.pending,
    required this.isDark,
    required this.pulseController,
    required this.onApprove,
    required this.onDismiss,
  });

  @override
  State<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<_PendingCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    var p = widget.pending;
    var dt = DateTime.fromMillisecondsSinceEpoch(p.detectedAtMs);
    var timeStr = DateFormat('dd MMM  hh:mm a').format(dt);
    var isDebit = p.isDebit;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDebit
                  ? AppColors.expense.withValues(alpha: 0.3)
                  : AppColors.income.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isDark ? Colors.black : Colors.grey).withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────────
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (isDebit ? AppColors.expense : AppColors.income)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDebit
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: isDebit ? AppColors.expense : AppColors.income,
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Text(
                  '₹${p.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDebit ? AppColors.expense : AppColors.income,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: widget.pulseController,
                  builder:
                      (_, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(
                            alpha: 0.15 + 0.1 * widget.pulseController.value,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        size: 12,
                        color: AppColors.textMutedDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.bankName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.payment_rounded,
                        size: 12,
                        color: AppColors.textMutedDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.paymentMethod,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                  if (p.accountLast4.isNotEmpty)
                    Text(
                      'A/c ending ····${p.accountLast4}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textMutedDark,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),

          // ── Time & merchant row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: AppColors.textMutedDark,
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedDark,
                  ),
                ),
                if (p.merchant.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.store_rounded,
                    size: 12,
                    color: AppColors.textMutedDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.merchant,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Expanded: raw SMS + actions ──────────────────────────────────────
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (widget.isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.rawSms,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color:
                        widget.isDark
                            ? AppColors.textMutedLight
                            : AppColors.textMutedDark,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],

          // ── Action buttons ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Dismiss'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      side: const BorderSide(
                        color: AppColors.expense,
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: widget.onDismiss,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add to Expenses'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showCategoryDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    var provider = context.read<AmountProvider>();
    var categories = provider.allCategories;
    String selectedCategory = categories.first;
    var notesController = TextEditingController(
      text: widget.pending.merchant.isNotEmpty ? widget.pending.merchant : '',
    );
    var isDark = widget.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Categorize Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${widget.pending.amount.toStringAsFixed(2)} via ${widget.pending.paymentMethod}',
                        style: const TextStyle(
                          color: AppColors.textMutedDark,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category grid
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            categories.map((cat) {
                              var isSelected = cat == selectedCategory;
                              return GestureDetector(
                                onTap:
                                    () => setModalState(
                                      () => selectedCategory = cat,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : AppColors.primary.withValues(
                                              alpha: 0.08,
                                            ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(cat),
                                        size: 14,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        cat,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Notes field
                      const Text(
                        'Notes (optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Lunch at office, Grocery...',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Save Transaction'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onApprove(
                              selectedCategory,
                              notesController.text.trim(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'hostel':
        return Icons.hotel_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'recharge':
        return Icons.phone_android_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
