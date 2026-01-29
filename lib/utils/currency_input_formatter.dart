import 'package:flutter/services.dart';

/// A custom TextInputFormatter that formats numbers as Indonesian Rupiah
/// with thousand separators (dots).
/// 
/// Example: "1000000" becomes "1.000.000"
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the text is empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format with thousand separators
    String formatted = _formatWithThousandSeparator(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Formats a string of digits with Indonesian thousand separators (dots)
  String _formatWithThousandSeparator(String value) {
    final buffer = StringBuffer();
    int count = 0;
    
    for (int i = value.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
      count++;
    }
    
    return buffer.toString().split('').reversed.join('');
  }

  /// Parses a formatted currency string back to an integer
  /// Example: "1.000.000" becomes 1000000
  static int parseToInt(String formattedValue) {
    if (formattedValue.isEmpty) return 0;
    String digitsOnly = formattedValue.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  /// Formats an integer to Indonesian Rupiah format string
  /// Example: 1000000 becomes "1.000.000"
  static String formatFromInt(int value) {
    if (value == 0) return '0';
    
    String digits = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
      count++;
    }
    
    return buffer.toString().split('').reversed.join('');
  }
}
