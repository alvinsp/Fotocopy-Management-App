import 'package:intl/intl.dart';

extension CurrencyFormat on num {
  String toIDR() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}
