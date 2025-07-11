import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaintProFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final List<DropdownMenuItem<String>>? items;
  final String? value;
  final bool isEnabled;
  final FocusNode? focusNode;

  const PaintProFormField._({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
    this.items,
    this.value,
    this.isEnabled = true,
    this.focusNode,
  });

  // Build a text input field
  Widget _buildTextField(ThemeData theme) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      enabled: isEnabled,
      inputFormatters: inputFormatters,
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
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  // Factory for text input (strings)
  factory PaintProFormField.text({
    Key? key,
    required String label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    bool isEnabled = true,
    FocusNode? focusNode,
  }) {
    return PaintProFormField._(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      isEnabled: isEnabled,
      focusNode: focusNode,
    );
  }

  // Factory for numeric input
  factory PaintProFormField.number({
    Key? key,
    required String label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    bool decimal = false,
    bool isEnabled = true,
    FocusNode? focusNode,
  }) {
    return PaintProFormField._(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: decimal
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (!decimal) FilteringTextInputFormatter.digitsOnly,
      ],
      isEnabled: isEnabled,
      focusNode: focusNode,
    );
  }

  // Factory for dropdown selection
  factory PaintProFormField.dropdown({
    Key? key,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required void Function(String?)? onChanged,
    String? hintText,
    bool isEnabled = true,
    FocusNode? focusNode,
  }) {
    return PaintProFormField._(
      key: key,
      label: label,
      items: items,
      value: value,
      onChanged: onChanged,
      hintText: hintText,
      isEnabled: isEnabled,
      focusNode: focusNode,
    );
  }

  // Factory for phone input with formatting
  factory PaintProFormField.phone({
    Key? key,
    required String label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    bool isEnabled = true,
    FocusNode? focusNode,
  }) {
    return PaintProFormField._(
      key: key,
      label: label,
      hintText: hintText ?? '+1 (555) 123-4567',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        // You could add a custom formatter for phone numbers
      ],
      isEnabled: isEnabled,
      focusNode: focusNode,
    );
  }

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

        // Input field or dropdown
        if (items != null)
          _buildDropdownCustom(context, theme)
        else
          _buildTextField(theme),

        // Add some bottom spacing
        const SizedBox(height: 16),
      ],
    );
  }

  // Build a dropdown custom that expands a list below the field
  Widget _buildDropdownCustom(BuildContext context, ThemeData theme) {
    final selectedLabel = items
        ?.firstWhere(
          (item) => item.value == value,
          orElse: () => DropdownMenuItem<String>(
            value: null,
            child: Text(hintText ?? ''),
          ),
        )
        .child;

    return _DropdownField(
      label: label,
      hintText: hintText,
      items: items ?? [],
      value: value,
      onChanged: onChanged,
      isEnabled: isEnabled,
      selectedLabel: selectedLabel,
      theme: theme,
    );
  }
}

class _DropdownField extends StatefulWidget {
  final String label;
  final String? hintText;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final void Function(String?)? onChanged;
  final bool isEnabled;
  final Widget? selectedLabel;
  final ThemeData theme;

  const _DropdownField({
    required this.label,
    required this.hintText,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.isEnabled,
    required this.selectedLabel,
    required this.theme,
  });

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  bool _expanded = false;

  void _toggleDropdown() {
    if (widget.isEnabled) {
      setState(() {
        _expanded = !_expanded;
      });
    }
  }

  void _select(String? value) {
    setState(() {
      _expanded = false;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleDropdown,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              enabled: widget.isEnabled,
              controller: TextEditingController(
                text: widget.selectedLabel is Text
                    ? (widget.selectedLabel as Text).data
                    : widget.selectedLabel?.toString(),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: widget.theme.primaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ),
              style: widget.theme.textTheme.bodyMedium,
            ),
          ),
        ),
        if (_expanded)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.map((item) {
                return InkWell(
                  onTap: () => _select(item.value),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: DefaultTextStyle(
                      style:
                          widget.theme.textTheme.bodyMedium ??
                          const TextStyle(),
                      child: item.child,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
