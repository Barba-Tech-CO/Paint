import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/view/measurements/widgets/loading_widget.dart';
import 'package:paintpro/view/measurements/widgets/measurement_results_widget.dart';
import 'package:provider/provider.dart';

class MeasurementsView extends StatelessWidget {
  const MeasurementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancelar medição?'),
            content: const Text(
              'Se cancelar, os dados preenchidos serão perdidos. Deseja voltar para o início do projeto?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Ficar'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
        if (shouldLeave == true) {
          context.go('/new-project');
        }
      },
      child: ChangeNotifierProvider(
        create: (context) => MeasurementsViewModel(),
        child: Scaffold(
          body: Consumer<MeasurementsViewModel>(
            builder: (context, viewModel, child) {
              return viewModel.isLoading
                  ? const LoadingWidget()
                  : Scaffold(
                      appBar: PaintProAppBar(title: 'Measurements'),
                      body: MeasurementResultsWidget(
                        results: viewModel.measurementResults,
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
