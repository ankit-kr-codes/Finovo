import 'package:expen/core/theme.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  //Controllers
  TextEditingController numController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController subTitleController = TextEditingController();

  //Border design
  final OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide.none,
  );

  //NEW - DEV AIDAN H -
  DateTime todaysDate = DateTime.now(); //PULLING THE DATETIME FOR DISPLAY
  DateTime? selectedDate; //SETTING VAR FOR DATE SELECTOR

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(
        todaysDate.year,
        todaysDate.month - 1,
        todaysDate.day,
      ),
      lastDate: DateTime.now(),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Provider
    var amountProvider = Provider.of<AmountProvider>(context);
    var currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      //NEW - DEV AIDAN H - MAKES THE UI SCROLLABLE TO FIX SCREEN OVERFLOW
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.arrow_back_ios, color: AppColors.blue),
          ),
        ),
        leadingWidth: 50,
        centerTitle: true,
        title: const Text(
          "Add New Expense",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          //Saving expense data
          GestureDetector(
            onTap: () {
              //Check if the textfield is empty or not
              if (numController.text.isNotEmpty) {
                double? amount = double.tryParse(numController.text);
                String title = titleController.text;
                String subtitle = subTitleController.text;

                if (amount != null) {
                  selectedDate ??= todaysDate;
                  amountProvider.addAmount(
                    title,
                    subtitle,
                    amount,
                    selectedDate!,
                  ); //NEW - DEV AIDAN H - PASSING NEW DATE TO PROVIDER
                  context.pop();
                  //User will go to home screen and get a dialog box to notify that expense is added
                  showDialog<String>(
                    context: context,
                    builder:
                        (BuildContext context) => AlertDialog(
                          title: const Text('Amount added'),
                          content: const Text(
                            "Your expense has been added successfully!\n\nLong press to delete it.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                } else {
                  //Inform user that entered amount is invalid (means it's not a double value)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid amount"),
                      showCloseIcon: true,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
                numController.clear(); // This will clear the textfield
                titleController.clear(); // This will clear the textfield
              } else {
                //If textfield is empty then user will get this snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter an amount. Amount cannot be empty.",
                    ),
                    showCloseIcon: true,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        //NEW - DEV AIDAN H - MAKES THE UI SCROLLABLE TO FIX SCREEN OVERFLOW
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Getting amount from user
              SizedBox(
                width: 150,
                child: TextField(
                  controller: numController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightTransparent,
                    hintText: "0.00",
                    prefixIcon: SizedBox(
                      width: 0,
                      child: Center(
                        heightFactor: 0.2,
                        child: Text(
                          //This will show selected currency symbol
                          currencyProvider.selectedCurrencySymbol,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ),
                    prefixStyle: TextStyle(color: AppColors.grey),
                    border: _outlineInputBorder,
                    enabledBorder: _outlineInputBorder,
                    focusedBorder: _outlineInputBorder,
                    hoverColor: AppColors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              //Getting title from the user
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Expense Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightTransparent,
                  border: _outlineInputBorder,
                  enabledBorder: _outlineInputBorder,
                  focusedBorder: _outlineInputBorder,
                  hoverColor: AppColors.transparent,
                ),
              ),
              const SizedBox(height: 30),

              //Getting description from the user
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Expense Description"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subTitleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightTransparent,
                  border: _outlineInputBorder,
                  enabledBorder: _outlineInputBorder,
                  focusedBorder: _outlineInputBorder,
                  hoverColor: AppColors.transparent,
                ),
              ),
              const SizedBox(height: 30),
              //NEW - DEV AIDAN H - ALLOW USER TO SELECT DATE
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   "Please select a custom date for this expense\nOr leave it as the default",
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 15),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                        : DateFormat('dd MMMM yyyy').format(todaysDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0),
                      overlayColor: WidgetStatePropertyAll(
                        AppColors.transparent,
                      ),
                    ),
                    child: const Text("Change Date"),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
