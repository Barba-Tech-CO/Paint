import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../service/camera_service.dart';
import '../../service/photo_service.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  Future<void> _capturePhoto(BuildContext context) async {
    try {
      final cameraService = getIt<CameraService>();
      final photoService = getIt<PhotoService>();

      // Capture photo from camera
      final photoPath = await cameraService.capturePhoto();

      if (photoPath != null) {
        // Add photo to PhotoService
        await photoService.addPhoto(photoPath);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to zones after capturing photo
          context.push('/zones');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaintProAppBar(title: 'Camera'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => _capturePhoto(context),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera',
              style: GoogleFonts.albertSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture your photos here',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
