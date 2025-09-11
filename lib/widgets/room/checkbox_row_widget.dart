import 'package:flutter/material.dart';

class CheckboxRowWidget extends StatefulWidget {
  final Map<String, bool> items;
  final Function(String, bool) onItemChanged;

  const CheckboxRowWidget({
    super.key,
    required this.items,
    required this.onItemChanged,
  });

  @override
  State<CheckboxRowWidget> createState() =>
      _CheckboxRowWidgetState();
}

class _CheckboxRowWidgetState extends State<CheckboxRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widget.items.entries.map((entry) {
        return Row(
          children: [
            Text(entry.key),
            Checkbox(
              value: entry.value,
              onChanged: (val) {
                setState(() {
                  widget.items[entry.key] = val ?? false;
                });
                widget.onItemChanged(entry.key, val ?? false);
              },
              activeColor: Colors.blue,
            ),
          ],
        );
      }).toList(),
    );
  }
}
