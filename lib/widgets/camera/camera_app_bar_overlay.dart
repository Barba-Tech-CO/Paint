import 'package:flutter/material.dart';

import '../../widgets/appbars/camera_app_bar.dart';

class CameraAppBarOverlay extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onDonePressed;
  final String instructionText;
  final bool isDoneEnabled;

  const CameraAppBarOverlay({
    super.key,
    this.onBackPressed,
    this.onDonePressed,
    this.instructionText = 'Take between 3 - 9 photos',
    this.isDoneEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = CameraAppBar(
      onBackPressed: onBackPressed,
      onDonePressed: onDonePressed,
      instructionText: instructionText,
      isDoneEnabled: isDoneEnabled,
    );

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: appBar,
    );
  }
}
