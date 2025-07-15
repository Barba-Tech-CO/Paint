import 'package:flutter/material.dart';

class WallConditionWidget extends StatefulWidget {
  final String wallCondition;
  final Function(String) onConditionChanged;
  final List<String> conditions;

  const WallConditionWidget({
    super.key,
    required this.wallCondition,
    required this.onConditionChanged,
    this.conditions = const ['Excellent', 'Good', 'Fair', 'Poor'],
  });

  @override
  State<WallConditionWidget> createState() => _WallConditionWidgetState();
}

class _WallConditionWidgetState extends State<WallConditionWidget> {
  late String _selectedCondition;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.wallCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.conditions
          .map(
            (condition) => RadioListTile<String>(
              value: condition,
              contentPadding: EdgeInsets.zero,
              groupValue: _selectedCondition,
              onChanged: (val) {
                setState(() {
                  _selectedCondition = val!;
                });
                widget.onConditionChanged(val!);
              },
              title: Text(condition),
            ),
          )
          .toList(),
    );
  }
}
