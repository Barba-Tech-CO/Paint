import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/processing/processing_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';

class ProcessingView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? roomData;
  final Map<String, dynamic>? projectData;

  const ProcessingView({
    super.key,
    required this.capturedPhotos,
    this.roomData,
    this.projectData,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  late ProcessingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProcessingViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _startProcessing();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startProcessing() async {
    await _viewModel.startProcessing(
      capturedPhotos: widget.capturedPhotos,
      roomData: widget.roomData,
      projectData: widget.projectData,
    );

    if (mounted && !_viewModel.isProcessing) {
      _viewModel.navigateToZones(context);
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loading Animation
            Column(
              children: [
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
                    color: AppColors.textPrimary80,
                  ),
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _viewModel.progress,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    Text(
                      '${(_viewModel.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_viewModel.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${_viewModel.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
