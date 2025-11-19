import 'package:flutter/material.dart';

class CameraFocusOverlay extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final BoxFit fit;

  const CameraFocusOverlay({
    super.key,
    this.assetPath = 'assets/camera/focus_field.png',
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
