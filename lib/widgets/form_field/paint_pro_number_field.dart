import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NumberFieldKind { generic, phone, zip }

class PaintProNumberField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool decimal;
  final bool isEnabled;
  final FocusNode? focusNode;
  final NumberFieldKind kind;
  final TextInputAction? textInputAction;

  const PaintProNumberField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.decimal = false,
    this.isEnabled = true,
    this.focusNode,
    this.kind = NumberFieldKind.generic,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Number input field
        TextFormField(
          controller: controller,
          keyboardType: _resolveKeyboardType(),
          textInputAction: textInputAction,
          validator: validator ?? _defaultValidator,
          enabled: isEnabled,
          inputFormatters: [
            ..._resolveFormatters(),
          ],
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0), // Cinza claro
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0), // Cinza claro
                width: 1.0,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),

        // Add some bottom spacing
        const SizedBox(height: 16),
      ],
    );
  }

  TextInputType _resolveKeyboardType() {
    if (decimal && kind == NumberFieldKind.generic) {
      return const TextInputType.numberWithOptions(decimal: true);
    }
    switch (kind) {
      case NumberFieldKind.phone:
        return TextInputType.phone;
      case NumberFieldKind.zip:
        return TextInputType.number;
      case NumberFieldKind.generic:
        return TextInputType.number;
    }
  }

  List<TextInputFormatter> _resolveFormatters() {
    // Allow only digits by default (no decimals)
    if (decimal && kind == NumberFieldKind.generic) {
      return const <TextInputFormatter>[];
    }
    switch (kind) {
      case NumberFieldKind.phone:
        return <TextInputFormatter>[
          LengthLimitingTextInputFormatter(20),
          _PhoneNumberFormatter(),
        ];
      case NumberFieldKind.zip:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
          _ZipCodeFormatter(),
        ];
      case NumberFieldKind.generic:
        return <TextInputFormatter>[
          if (!decimal) FilteringTextInputFormatter.digitsOnly,
        ];
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    switch (kind) {
      case NumberFieldKind.phone:
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 10) {
          return 'Please enter a valid 10-digit phone number';
        }
        break;
      case NumberFieldKind.zip:
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 5) {
          return 'Please enter a valid 5-digit postal code';
        }
        break;
      case NumberFieldKind.generic:
        break;
    }
    return null;
  }
}

/// Formatter for US phone numbers (XXX) XXX-XXXX or +1 (XXX) XXX-XXXX
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If user is typing +, allow it
    if (newValue.text.startsWith('+')) {
      // Keep the + and format the rest
      final withoutPlus = newValue.text.substring(1);
      final digitsOnly = withoutPlus.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.isEmpty) {
        return newValue.copyWith(text: '+');
      }

      // If it starts with 1, format as +1 (XXX) XXX-XXXX
      if (digitsOnly.startsWith('1')) {
        final phoneDigits = digitsOnly.substring(1); // Remove the 1

        if (phoneDigits.isEmpty) {
          return newValue.copyWith(text: '+1 ');
        }

        String formatted = '+1 ';
        if (phoneDigits.length <= 3) {
          formatted += '($phoneDigits';
        } else if (phoneDigits.length <= 6) {
          formatted +=
              '(${phoneDigits.substring(0, 3)}) ${phoneDigits.substring(3)}';
        } else {
          final limitedDigits = phoneDigits.length > 10
              ? phoneDigits.substring(0, 10)
              : phoneDigits;
          formatted +=
              '(${limitedDigits.substring(0, 3)}) ${limitedDigits.substring(3, 6)}-${limitedDigits.substring(6)}';
        }

        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else {
        // If it doesn't start with 1, just format as +XXX XXX-XXXX
        String formatted = '+';
        if (digitsOnly.length <= 3) {
          formatted += digitsOnly;
        } else if (digitsOnly.length <= 6) {
          formatted +=
              '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
        } else {
          final limitedDigits = digitsOnly.length > 10
              ? digitsOnly.substring(0, 10)
              : digitsOnly;
          formatted +=
              '${limitedDigits.substring(0, 3)} ${limitedDigits.substring(3, 6)}-${limitedDigits.substring(6)}';
        }

        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    } else {
      // Remove all non-digit characters
      final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.isEmpty) {
        return newValue.copyWith(text: '');
      }

      // Format as (XXX) XXX-XXXX
      String formatted = '';
      if (digitsOnly.length <= 3) {
        formatted = '($digitsOnly';
      } else if (digitsOnly.length <= 6) {
        formatted =
            '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3)}';
      } else {
        final limitedDigits = digitsOnly.length > 10
            ? digitsOnly.substring(0, 10)
            : digitsOnly;
        formatted =
            '(${limitedDigits.substring(0, 3)}) ${limitedDigits.substring(3, 6)}-${limitedDigits.substring(6)}';
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

/// Formatter for US zip codes XXXXX
class _ZipCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limit to 5 digits
    final formatted = digitsOnly.length > 5
        ? digitsOnly.substring(0, 5)
        : digitsOnly;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
