/// Parses bank transaction SMS messages.
/// Supports UPI, NEFT, IMPS, card swipes, ATM, and net banking SMS formats
/// from major Indian banks (SBI, HDFC, ICICI, Axis, Kotak, PNB, BOB, etc.)
library;

class ParsedTransaction {
  final double amount;
  final bool isDebit; // true = expense, false = income/credit
  final String bankName;
  final String paymentMethod; // UPI, Debit Card, Credit Card, NEFT, IMPS, ATM
  final String? merchant; // extracted merchant/payee name if present
  final String? accountLast4; // last 4 digits of account/card
  final String rawSms;
  final DateTime detectedAt;

  ParsedTransaction({
    required this.amount,
    required this.isDebit,
    required this.bankName,
    required this.paymentMethod,
    this.merchant,
    this.accountLast4,
    required this.rawSms,
    required this.detectedAt,
  });

  @override
  String toString() =>
      'ParsedTransaction(amount: $amount, isDebit: $isDebit, bank: $bankName, method: $paymentMethod, merchant: $merchant)';
}

class SmsParser {
  // ── Trusted bank sender IDs (alphanumeric & shortcodes) ─────────────────────
  static const List<String> _trustedSenders = [
    // SBI
    'SBIINB', 'SBIPSG', 'SBIUPI', 'SBI', 'SBIATM', 'SBICRD',
    // HDFC
    'HDFCBK', 'HDFCBNK', 'HDFC', 'HDFCCC',
    // ICICI
    'ICICIB', 'ICICI', 'ICICIG', 'ICICIBANK',
    // Axis
    'AXISBK', 'AXISBANK', 'AXIS',
    // Kotak
    'KOTAKB', 'KOTAK', 'KOTAKBK',
    // PNB
    'PNBSMS', 'PNBNEW', 'PNB',
    // Canara
    'CANARABK', 'CANBNK', 'CANARA',
    // BOB - Bank of Baroda
    'BOBIBNK', 'BOBSMS',
    // Union Bank
    'UNIONB', 'UBIIND',
    // IndusInd
    'INDBNK', 'INDUSLND',
    // Yes Bank
    'YESBNG', 'YESBANK',
    // IDFC
    'IDFCFB', 'IDFCBK',
    // RBL
    'RBLBNK',
    // Federal
    'FEDFIN',
    // PayTm
    'PYTMBNK', 'PAYTM',
    // Amazon Pay
    'AMAZON',
    // PhonePe
    'PHONPE', 'PPEBNK',
    // Google Pay
    'GPAY',
    // Juspay
    'JUSPAY',
  ];

  // ── Amount extraction patterns ───────────────────────────────────────────────
  // Covers: Rs. 1,234.56 | INR 1234 | ₹1,234.56 | Rs 1234.00
  static final RegExp _amountRegex = RegExp(
    r'(?:Rs\.?|INR|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // ── Debit keyword patterns ───────────────────────────────────────────────────
  static final RegExp _debitRegex = RegExp(
    r'\b(debited|debit|paid|payment|spent|withdrawn|purchase|transferred out|dr\.?)\b',
    caseSensitive: false,
  );

  // ── Credit keyword patterns ──────────────────────────────────────────────────
  static final RegExp _creditRegex = RegExp(
    r'\b(credited|credit|received|refund|cashback|cr\.?)\b',
    caseSensitive: false,
  );

  // ── Payment method patterns ──────────────────────────────────────────────────
  static final RegExp _upiRegex = RegExp(r'\bUPI\b', caseSensitive: false);
  static final RegExp _neftRegex = RegExp(r'\bNEFT\b', caseSensitive: false);
  static final RegExp _impsRegex = RegExp(r'\bIMPS\b', caseSensitive: false);
  static final RegExp _rtgsRegex = RegExp(r'\bRTGS\b', caseSensitive: false);
  static final RegExp _atmRegex = RegExp(
    r'\b(ATM|cash withdrawal)\b',
    caseSensitive: false,
  );
  static final RegExp _creditCardRegex = RegExp(
    r'\b(credit card|CC|CreditCard)\b',
    caseSensitive: false,
  );
  static final RegExp _debitCardRegex = RegExp(
    r'\b(debit card|DC|DebitCard|PoS|POS)\b',
    caseSensitive: false,
  );
  static final RegExp _netBankingRegex = RegExp(
    r'\b(net banking|NetBanking|internet banking)\b',
    caseSensitive: false,
  );

  // ── Merchant/payee extraction ─────────────────────────────────────────────────
  // e.g. "to AMAZON", "at MCDONALDS", "to VPA merchant@upi"
  static final RegExp _merchantToRegex = RegExp(
    r'(?:to|at|towards|for)\s+([A-Za-z0-9@._\-\s]{3,40}?)(?:\s+(?:on|via|through|for|Ref|A/c|UPI|using|by|with)|$)',
    caseSensitive: false,
  );

  // UPI VPA extraction: merchant@okicici etc.
  static final RegExp _vpaRegex = RegExp(
    r'([a-z0-9._\-]+@[a-z]+)',
    caseSensitive: false,
  );

  // ── Account/card last 4 digits ────────────────────────────────────────────────
  static final RegExp _accountRegex = RegExp(
    r'(?:A/c|Acct|Card|account|ending|XX|x{2,})\s*(?:no\.?)?\s*[Xx*]*([0-9]{4})\b',
    caseSensitive: false,
  );

  // ── Bank name map (sender prefix → display name) ──────────────────────────────
  static const Map<String, String> _bankNameMap = {
    'SBI': 'SBI',
    'HDFC': 'HDFC Bank',
    'ICICI': 'ICICI Bank',
    'AXIS': 'Axis Bank',
    'KOTAK': 'Kotak Bank',
    'PNB': 'Punjab National Bank',
    'CANARA': 'Canara Bank',
    'BOB': 'Bank of Baroda',
    'UNION': 'Union Bank',
    'INDUS': 'IndusInd Bank',
    'YES': 'Yes Bank',
    'IDFC': 'IDFC First Bank',
    'RBL': 'RBL Bank',
    'FED': 'Federal Bank',
    'PAYTM': 'Paytm Payments Bank',
    'PYTM': 'Paytm Payments Bank',
    'AMAZON': 'Amazon Pay',
    'PHONE': 'PhonePe',
    'PPE': 'PhonePe',
    'GPAY': 'Google Pay',
  };

  /// Returns true if the SMS sender is from a trusted banking/financial institution.
  static bool isTrustedBankSender(String sender) {
    var s = sender.toUpperCase().trim();
    return _trustedSenders.any((t) => s.contains(t) || s == t);
  }

  /// Returns true if the SMS body looks like a bank transaction notification.
  static bool looksLikeTransaction(String body) {
    var hasAmount = _amountRegex.hasMatch(body);
    var hasDirection =
        _debitRegex.hasMatch(body) || _creditRegex.hasMatch(body);
    return hasAmount && hasDirection;
  }

  /// Parses a bank SMS and returns a [ParsedTransaction] or null if unrecognized.
  static ParsedTransaction? parse(String sender, String body) {
    if (!looksLikeTransaction(body)) return null;

    // ── Extract amount ───────────────────────────────────────────────────────
    var amountMatch = _amountRegex.firstMatch(body);
    if (amountMatch == null) return null;
    var rawAmount = amountMatch.group(1)!.replaceAll(',', '');
    var amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return null;

    // ── Determine debit/credit ───────────────────────────────────────────────
    var isDebit = _debitRegex.hasMatch(body);
    // If both keywords appear (unusual), prefer debit (conservative)

    // ── Determine payment method ─────────────────────────────────────────────
    String paymentMethod = 'Bank Transfer';
    if (_upiRegex.hasMatch(body)) {
      paymentMethod = 'UPI';
    } else if (_creditCardRegex.hasMatch(body)) {
      paymentMethod = 'Credit Card';
    } else if (_debitCardRegex.hasMatch(body)) {
      paymentMethod = 'Debit Card';
    } else if (_atmRegex.hasMatch(body)) {
      paymentMethod = 'ATM';
    } else if (_neftRegex.hasMatch(body)) {
      paymentMethod = 'NEFT';
    } else if (_impsRegex.hasMatch(body)) {
      paymentMethod = 'IMPS';
    } else if (_rtgsRegex.hasMatch(body)) {
      paymentMethod = 'RTGS';
    } else if (_netBankingRegex.hasMatch(body)) {
      paymentMethod = 'Net Banking';
    }

    // ── Extract bank name ────────────────────────────────────────────────────
    var bankName = _extractBankName(sender.toUpperCase());

    // ── Extract account last 4 ───────────────────────────────────────────────
    var accountMatch = _accountRegex.firstMatch(body);
    var accountLast4 = accountMatch?.group(1);

    // ── Extract merchant/payee ───────────────────────────────────────────────
    String? merchant = _extractMerchant(body);

    return ParsedTransaction(
      amount: amount,
      isDebit: isDebit,
      bankName: bankName,
      paymentMethod: paymentMethod,
      merchant: merchant,
      accountLast4: accountLast4,
      rawSms: body,
      detectedAt: DateTime.now(),
    );
  }

  static String _extractBankName(String sender) {
    for (var entry in _bankNameMap.entries) {
      if (sender.contains(entry.key)) return entry.value;
    }
    // Fallback: use sender as-is but clean up
    return sender.replaceAll(RegExp(r'[^A-Z ]'), '').trim();
  }

  static String? _extractMerchant(String body) {
    // Try merchant regex first
    var merchantMatch = _merchantToRegex.firstMatch(body);
    if (merchantMatch != null) {
      var raw = merchantMatch.group(1)?.trim() ?? '';
      if (raw.isNotEmpty && raw.length > 2) {
        // Clean up the VPA portion from merchant name
        var cleaned = raw.replaceAll(_vpaRegex, '').trim();
        if (cleaned.isNotEmpty) return _toTitleCase(cleaned);
        return _toTitleCase(raw);
      }
    }

    // Try VPA extraction as fallback for UPI
    var vpaMatch = _vpaRegex.firstMatch(body);
    if (vpaMatch != null) {
      return vpaMatch.group(1);
    }

    return null;
  }

  static String _toTitleCase(String s) {
    return s
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
