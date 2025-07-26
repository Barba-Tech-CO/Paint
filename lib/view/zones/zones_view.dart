import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/viewmodel/zones/zones_card_viewmodel.dart';
import 'package:paintpro/view/zones/widgets/loading_widget.dart';
import 'package:paintpro/view/zones/widgets/zones_results_widget.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

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
            title: const Text('Exit zones?'),
            content: const Text(
              'Are you sure you wat to go back? Any unsaved measurements will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Yes, go back'),
              ),
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
        if (shouldLeave == true) {
          if (context.mounted) {
            context.go('/new-project');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<ZonesCardViewmodel>(
          builder: (context, viewModel, child) {
            // Inicializa o ViewModel apenas uma vez
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.state == ZonesState.initial) {
                viewModel.initialize();
              }
            });
            return viewModel.isLoading
                ? const LoadingWidget()
                : Scaffold(
                    appBar: PaintProAppBar(title: 'Zones'),
                    body: ZonesResultsWidget(
                      results: const {},
                    ),
                  );
          },
        ),
      ),
    );
  }
}
