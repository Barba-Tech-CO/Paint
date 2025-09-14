import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_control_button.dart';
import 'shutter_button.dart';

class CameraControlsBar extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onToggleFlash;
  final VoidCallback? onZoomTap;
  final FlashMode flashMode;
  final String zoomText;
  final bool isShutterDisabled;

  const CameraControlsBar({
    super.key,
    required this.onTakePhoto,
    required this.onToggleFlash,
    this.onZoomTap,
    this.flashMode = FlashMode.off,
    this.zoomText = '2x',
    this.isShutterDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Zoom Button
            CameraControlButton.zoom(
              onTap: onZoomTap,
              zoomText: zoomText,
            ),

            // Shutter Button
            ShutterButton(
              onTap: onTakePhoto,
              isDisabled: isShutterDisabled,
            ),

            // Flash Button
            CameraControlButton.flash(
              onTap: onToggleFlash,
              isFlashOn: flashMode != FlashMode.off,
            ),
          ],
        ),
      ),
    );
  }
}
