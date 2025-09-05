import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/select_colors/select_colors_viewmodel.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';
import '../widgets/buttons/paint_pro_button.dart';
import 'widgets/color_grid_widget.dart';

class SelectColorsView extends StatefulWidget {
  const SelectColorsView({super.key});

  @override
  State<SelectColorsView> createState() => _SelectColorsViewState();
}

class _SelectColorsViewState extends State<SelectColorsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SelectColorsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SelectColorsViewModel>();
    _tabController = TabController(
      length: _viewModel.brands.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Select Colors',
        tabs: _viewModel.brands.map((brand) => Tab(text: brand)).toList(),
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        toolbarHeight: 80,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Exibir mensagem de erro se houver
            if (_viewModel.errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: _viewModel.brands
                          .map(
                            (brand) => ColorGridWidget(
                              brand: brand,
                              colors: _viewModel.colors,
                              onColorTap: (colorData) {
                                _viewModel.selectColor(colorData, brand);
                              },
                            ),
                          )
                          .toList(),
                    ),
            ),
            PaintProButton(
              text: 'Generate Estimate',
              onPressed: _viewModel.canGenerateEstimate
                  ? () async {
                      await _viewModel.generateEstimate();
                      if (_viewModel.errorMessage == null && context.mounted) {
                        context.push('/overview-measurements');
                      }
                    }
                  : null,
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
