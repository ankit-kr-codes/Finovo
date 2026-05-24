import 'package:expen/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  interactive: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader("Finovo Terms of Service", "Last updated: May 2026"),
                          const SizedBox(height: 24),
                          _buildSectionTitle(1, "Acceptance of Terms"),
                          _buildBodyText(
                            "By downloading, installing, or using the Finovo mobile application (\"App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not install or use the App.",
                          ),
                          _buildSectionTitle(2, "Description of Service"),
                          _buildBodyText(
                            "Finovo is a personal finance management tool that operates locally on your device. It allows users to track income, record expenses, manage budgets, set financial goals, track recurring items, and auto-detect bank transaction details locally via device SMS message parsing. All information processed remains on your physical device.",
                          ),
                          _buildSectionTitle(3, "SMS Parsing & Local Detection"),
                          _buildBodyText(
                            "If you grant permissions, Finovo reads bank-related SMS messages to detect transactions. You acknowledge and agree that:\n"
                            "• The SMS reading and parsing happens entirely on your local device.\n"
                            "• No SMS content is transmitted to external servers.\n"
                            "• Finovo relies on pattern matching and does not guarantee 100% accuracy in detecting every transaction or amount. It is your responsibility to review and verify all logged transactions.",
                          ),
                          _buildSectionTitle(4, "Data Privacy & Local Storage"),
                          _buildBodyText(
                            "All transactions, budget thresholds, SMS history log structures, and configurations are stored in an encrypted/local Hive database directly on your device. Finovo does not host databases storing your credentials or transaction logs. Deleting the App will result in the permanent loss of all stored data unless you have manually generated an export (CSV, Excel, or PDF).",
                          ),
                          _buildSectionTitle(5, "User Responsibilities"),
                          _buildBodyText(
                            "You are solely responsible for:\n"
                            "• Safeguarding your device and maintaining the confidentiality of any local passcode or biometric lock.\n"
                            "• Exporting and backing up your database periodically using the export utilities provided.\n"
                            "• Verifying the accuracy of the financial records.",
                          ),
                          _buildSectionTitle(6, "No Financial or Legal Advice"),
                          _buildBodyText(
                            "The App is provided for informational and tracking purposes only. Finovo does not offer financial advice, accounting audits, tax advice, or professional banking recommendations.",
                          ),
                          _buildSectionTitle(7, "Disclaimer of Warranties"),
                          _buildBodyText(
                            "The App is provided on an \"AS IS\" and \"AS AVAILABLE\" basis without warranties of any kind, either express or implied, including but not limited to compatibility, reliability of financial reports, or fitness for a particular purpose.",
                          ),
                          _buildSectionTitle(8, "Limitation of Liability"),
                          _buildBodyText(
                            "In no event shall the developers or copyright holders of Finovo be liable for any direct, indirect, incidental, special, or consequential damages (including loss of financial data, incorrect balance calculation, or system failure) arising out of the use or inability to use the App.",
                          ),
                          _buildSectionTitle(9, "Changes to Terms"),
                          _buildBodyText(
                            "We reserve the right to modify these Terms at any time. Your continued use of the App following any updates constitutes acceptance of the new Terms.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text(
                      "I Agree & Accept",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String lastUpdated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          lastUpdated,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMutedDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(int number, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}
