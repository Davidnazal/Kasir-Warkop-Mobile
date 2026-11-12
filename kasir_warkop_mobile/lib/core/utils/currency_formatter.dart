import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _decimalFormat = NumberFormat.decimalPattern(
    'id_ID',
  );

  static String format(num amount) => _idrFormat.format(amount);

  static String formatNumber(num amount) => _decimalFormat.format(amount);
}

/// Memformat input angka secara otomatis dengan pemisah ribuan titik (contoh: `5000` -> `5.000`).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final parsed = int.tryParse(digitsOnly);
    if (parsed == null) {
      return oldValue;
    }

    final formatted = CurrencyFormatter.formatNumber(parsed);

    // Hitung jumlah digit sebelum kursor pada teks baru agar posisi kursor tetap natural.
    final rawCursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );
    final digitsBeforeCursor = newValue.text
        .substring(0, rawCursor)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    var formattedCursor = 0;
    var seenDigits = 0;
    while (formattedCursor < formatted.length &&
        seenDigits < digitsBeforeCursor) {
      if (RegExp(r'[0-9]').hasMatch(formatted[formattedCursor])) {
        seenDigits++;
      }
      formattedCursor++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursor),
    );
  }
}
