import 'package:flutter/material.dart';

class SimpleCheckboxListWidget extends StatefulWidget {
  final Map<String, bool> items;
  final Function(String, bool) onItemChanged;
  final bool
  isRow; // true para layout horizontal (Accent Wall), false para vertical (Elements to Paint)

  const SimpleCheckboxListWidget({
    super.key,
    required this.items,
    required this.onItemChanged,
    this.isRow = false,
  });

  @override
  State<SimpleCheckboxListWidget> createState() =>
      _SimpleCheckboxListWidgetState();
}

class _SimpleCheckboxListWidgetState extends State<SimpleCheckboxListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isRow) {
      // Layout horizontal para Accent Wall (Row: texto + checkbox)
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
    } else {
      // Layout vertical para Elements to Paint (CheckboxListTile)
      return Column(
        children: widget.items.entries.map((entry) {
          return CheckboxListTile(
            value: entry.value,
            onChanged: (val) {
              setState(() {
                widget.items[entry.key] = val ?? false;
              });
              widget.onItemChanged(entry.key, val ?? false);
            },
            title: Text(entry.key),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: Colors.blue,
          );
        }).toList(),
      );
    }
  }
}
