import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/view/measurements/widgets/loading_widget.dart';
import 'package:paintpro/view/measurements/widgets/measurement_results_widget.dart';
import 'package:provider/provider.dart';

class MeasurementsView extends StatelessWidget {
  const MeasurementsView({super.key});

  Future<void> _handleBackPress(BuildContext context) async {
    final bool shouldPop =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Measurements'),
            content: const Text(
              'Are you sure you want to go back? Any unsaved measurements will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes, go back'),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (shouldPop) {
      // ignore: use_build_context_synchronously
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeasurementsViewModel(),
      child: Scaffold(
        body: Consumer<MeasurementsViewModel>(
          builder: (context, viewModel, child) {
            return viewModel.isLoading
                ? const LoadingWidget()
                : PopScope(
                    canPop: false, // Prevent default back behavior
                    onPopInvokedWithResult: (didPop, result) async {
                      if (didPop) return;
                      await _handleBackPress(context);
                    },
                    child: Scaffold(
                      appBar: PaintProAppBar(
                        title: 'Measurements',
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => _handleBackPress(context),
                        ),
                      ),
                      body: MeasurementResultsWidget(
                        results: viewModel.measurementResults,
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
