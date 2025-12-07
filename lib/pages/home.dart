import 'package:expen/core/theme.dart';
import 'package:expen/core/currency_symbol.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //Provider
    var amountProvider = Provider.of<AmountProvider>(context);
    double totalAmount = amountProvider.totalAmount;

    //For getting size of screen
    Size mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: "",
            itemBuilder:
                (context) => [
                  //For deleting all the expense
                  PopupMenuItem(
                    onTap: () {
                      showDialog<String>(
                        context: context,
                        builder:
                            (BuildContext context) => AlertDialog(
                              title: const Text(
                                'Are you sure you want to delete all your expenses?',
                              ),
                              content: const Text(
                                "You won't be able to restore it later.",
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    amountProvider.deleteAllExpenses();
                                    context.pop();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Text(
                      "Delete All Expenses",
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 20),
          //
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: mediaQuery.height * 0.25,
            child: Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${currencySymbol[currencyProvider.selectedCurrencyIndex]["symbol"]}${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 28,
                        color:
                            amountProvider.range < amountProvider.totalAmount
                                ? AppColors.red
                                : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Total Spent",
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                  ],
                );
              },
            ),
          ),

          if (amountProvider.amounts.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "Nothing to show here!",
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            ),

          Flexible(
            //This will show all expenses
            child: ListView.builder(
              itemCount: amountProvider.amounts.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var amount = amountProvider.amounts[index];

                return Column(
                  children: [
                    ListTile(
                      //For deleting specific expense
                      onLongPress: () {
                        showDialog<String>(
                          context: context,
                          builder:
                              (BuildContext context) => AlertDialog(
                                title: const Text(
                                  'Are you sure you want to delete this expense?',
                                ),
                                content: const Text(
                                  "This action cannot be undone.",
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      amountProvider.deleteAmount(amount);
                                      context.pop();
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      title: Text(
                        amount.title.isEmpty ? "Other" : amount.title,
                      ),
                      trailing: Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${currencySymbol[currencyProvider.selectedCurrencyIndex]["symbol"]}${amount.amount.toStringAsFixed(1)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                amountProvider.showDateTime
                                    ? amount.dateTime
                                    : "",
                              ),
                            ],
                          );
                        },
                      ),
                      subtitle:
                          amount.subtitle.isEmpty
                              ? null
                              : Text(amount.subtitle),

                      minVerticalPadding: 15,
                    ),
                    Divider(
                      color: AppColors.grey,
                      thickness: 0.5,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      //Navigation for settings and chart
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        fixedColor: AppColors.darkGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        enableFeedback: false,
        onTap: (value) {
          if (value == 0) {
            context.push('/chart');
          } else if (value == 2) {
            context.push('/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "",
          ),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),

      //For adding expense
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 16,
            child: FloatingActionButton(
              elevation: 0,
              onPressed: () => context.push('/addexpense'),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
