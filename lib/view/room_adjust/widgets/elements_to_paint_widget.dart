import 'package:flutter/material.dart';

class ElementsToPaintWidget extends StatefulWidget {
  final Map<String, bool> elements;
  final Function(String, bool) onElementChanged;

  const ElementsToPaintWidget({
    super.key,
    required this.elements,
    required this.onElementChanged,
  });

  @override
  State<ElementsToPaintWidget> createState() => _ElementsToPaintWidgetState();
}

class _ElementsToPaintWidgetState extends State<ElementsToPaintWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.elements.keys
          .map(
            (key) => CheckboxListTile(
              value: widget.elements[key],
              onChanged: (val) {
                setState(() {
                  widget.elements[key] = val ?? false;
                });
                widget.onElementChanged(key, val ?? false);
              },
              title: Text(key),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: Colors.blue,
            ),
          )
          .toList(),
    );
  }
}
