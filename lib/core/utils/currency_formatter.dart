import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount, {bool showSign = false}) {
    final formatted = _formatter.format(amount.abs());
    if (!showSign) return formatted;
    if (amount > 0) return '+$formatted';
    if (amount < 0) return '-$formatted';
    return formatted;
  }
}
