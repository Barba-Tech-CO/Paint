import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/view/zones/widgets/loading_widget.dart';
import 'package:paintpro/view/zones/widgets/measurement_results_widget.dart';
import 'package:provider/provider.dart';

class ZonesView extends StatelessWidget {
  const ZonesView({super.key});

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
                onPressed: () => context.pop(true),
                child: const Text('Voltar'),
              ),
              TextButton(
                onPressed: () => context.pop(false),
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
          backgroundColor: AppColors.background,
          body: Consumer<MeasurementsViewModel>(
            builder: (context, viewModel, child) {
              return viewModel.isLoading
                  ? const LoadingWidget()
                  : Scaffold(
                      appBar: PaintProAppBar(title: 'Zones'),
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
