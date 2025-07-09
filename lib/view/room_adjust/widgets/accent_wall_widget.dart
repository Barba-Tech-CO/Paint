import 'package:flutter/material.dart';

class AccentWallWidget extends StatefulWidget {
  final bool accentWall;
  final Function(bool) onAccentWallChanged;
  final String? label;

  const AccentWallWidget({
    super.key,
    required this.accentWall,
    required this.onAccentWallChanged,
    this.label = 'Include accent wall',
  });

  @override
  State<AccentWallWidget> createState() => _AccentWallWidgetState();
}

class _AccentWallWidgetState extends State<AccentWallWidget> {
  late bool _accentWall;

  @override
  void initState() {
    super.initState();
    _accentWall = widget.accentWall;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label ?? 'Include accent wall'),
        Switch(
          value: _accentWall,
          onChanged: (val) {
            setState(() {
              _accentWall = val;
            });
            widget.onAccentWallChanged(val);
          },
        ),
      ],
    );
  }
}
