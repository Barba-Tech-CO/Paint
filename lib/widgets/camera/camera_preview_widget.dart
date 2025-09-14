import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isInitialized;
  final Color backgroundColor;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    required this.isInitialized,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialized && cameraController != null) {
      return Positioned.fill(
        child: CameraPreview(cameraController!),
      );
    }

    return Container(
      color: backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
