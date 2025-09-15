import 'package:flutter/material.dart';
import '../../helpers/loading_helper.dart';
import '../../config/app_colors.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';

class ProcessingView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? roomData;

  const ProcessingView({
    super.key,
    required this.capturedPhotos,
    this.roomData,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    // Simula processamento entre 3s a 5s
    final processingTime = Duration(
      milliseconds: 3000 + (DateTime.now().millisecondsSinceEpoch % 2000),
    );

    await Future.delayed(processingTime);

    if (mounted) {
      LoadingHelper.navigateToPhotoProcessing(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Processing...',
        backgroundColor: AppColors.primary,
        textColor: AppColors.textOnPrimary,
        toolbarHeight: 80,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Loading Animation
              Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculating measurements...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
