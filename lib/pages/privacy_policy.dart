import 'package:expen/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
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
                          _buildHeader("Finovo Privacy Policy", "Last updated: May 2026"),
                          const SizedBox(height: 24),
                          _buildSectionTitle(1, "Introduction"),
                          _buildBodyText(
                            "At Finovo, we value your privacy above everything else. This Privacy Policy details how we handle information in the Finovo mobile application (\"App\"). Our core principle is simple: your financial data belongs to you, and it stays on your device.",
                          ),
                          _buildSectionTitle(2, "Data We Access & How We Use It"),
                          _buildBodyText(
                            "• SMS Messages: If you choose to enable the SMS Auto-Detect feature, the App requests permission to read SMS messages. The App only scans incoming or stored messages on the device that match specific bank formats to extract transaction amounts and merchant names.\n"
                            "• User Inputs: Any category customizations, manual transaction logs, budget settings, or currency preferences are entered by you directly into the App.",
                          ),
                          _buildSectionTitle(3, "Strictly Local Processing & Storage"),
                          _buildBodyText(
                            "We do not collect, upload, share, or sell your personal or financial information. All processing (including SMS text parsing and budget progress tracking) occurs locally on your physical device.\n"
                            "• No Cloud Uploads: We do not operate databases, remote backup servers, or telemetry portals that store your financial transactions.\n"
                            "• Local Database: All records are stored on your device using a local Hive database structure.",
                          ),
                          _buildSectionTitle(4, "Device Permissions"),
                          _buildBodyText(
                            "To provide optional features, the App may request:\n"
                            "• Receive SMS & Read SMS: Used exclusively to auto-detect bank debit/credit transaction messages.\n"
                            "• Notifications: Used locally to send category prompt reminders when new SMS transactions are detected.",
                          ),
                          _buildSectionTitle(5, "Data Security"),
                          _buildBodyText(
                            "Since your data resides entirely on your device, its security depends on the security features of your mobile phone. We recommend securing your device with PIN, password, or biometric authentication to prevent unauthorized physical access to your financial data.",
                          ),
                          _buildSectionTitle(6, "Export & Data Deletion"),
                          _buildBodyText(
                            "• Data Export: You can export your data to CSV, Excel, or PDF report documents at any time. These documents are saved on your local device storage under your full control.\n"
                            "• Complete Deletion: You can wipe all transaction and preference data permanently by using the \"Reset All Data\" option in App Settings or by uninstalling the App.",
                          ),
                          _buildSectionTitle(7, "Children's Privacy"),
                          _buildBodyText(
                            "The App is suitable for general audiences. Since we do not collect any personal data, we do not knowingly or unknowingly collect or store information from children under the age of 13.",
                          ),
                          _buildSectionTitle(8, "Changes to this Privacy Policy"),
                          _buildBodyText(
                            "We may update this Privacy Policy from time to time to reflect changes in our practices or legal obligations. We will notify you of any changes by updating the \"Last updated\" date at the top of this policy.",
                          ),
                          _buildSectionTitle(9, "Contact Us"),
                          _buildBodyText(
                            "If you have any questions or feedback about our local privacy model, feel free to contact us at: ankit.kr.codes@gmail.com",
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
                      "Dismiss",
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
