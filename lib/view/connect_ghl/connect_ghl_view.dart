import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/cards/connect_ghl_info_card_widget.dart';
import '../../widgets/connect_ghl/connect_ghl_action_handler_widget.dart';
import '../../widgets/connect_ghl/connect_ghl_delete_button_widget.dart';
import '../../widgets/connect_ghl/connect_ghl_form_fields_widget.dart';
import '../../widgets/connect_ghl/connect_ghl_save_button_widget.dart';
import '../../viewmodel/connect_ghl/connect_ghl_viewmodel.dart';

class ConnectGhlView extends StatefulWidget {
  const ConnectGhlView({super.key});

  @override
  State<ConnectGhlView> createState() => _ConnectGhlViewState();
}

class _ConnectGhlViewState extends State<ConnectGhlView> {
  late final ConnectGhlViewModel _connectGhlViewModel;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _locationIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectGhlViewModel = getIt<ConnectGhlViewModel>();
    _connectGhlViewModel.addListener(_onViewModelChanged);
    _connectGhlViewModel.loadGhlData();
  }

  void _onViewModelChanged() {
    final config = _connectGhlViewModel.ghlConfig;
    final isLoading = _connectGhlViewModel.isLoading;
    final hasExisting = _connectGhlViewModel.hasExistingConfig;

    // Populate controllers when data is loaded
    if (config != null && !isLoading) {
      // Only update if the text is different to avoid cursor jumping
      if (_apiKeyController.text != config.apiKey) {
        _apiKeyController.text = config.apiKey;
      }

      if (_locationIdController.text != config.locationId) {
        _locationIdController.text = config.locationId;
      }
    } else if (config == null && !isLoading && !hasExisting) {
      // Only clear when explicitly disconnected
      _apiKeyController.clear();
      _locationIdController.clear();
    }
  }

  @override
  void dispose() {
    _connectGhlViewModel.removeListener(_onViewModelChanged);
    _apiKeyController.dispose();
    _locationIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConnectGhlViewModel>.value(
      value: _connectGhlViewModel,
      child: ConnectGhlActionHandlerWidget(
        apiKeyController: _apiKeyController,
        locationIdController: _locationIdController,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: 'Connect Go High Level',
            toolbarHeight: 80,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textOnPrimary,
              ),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConnectGhlInfoCardWidget(),
                SizedBox(height: 32.h),
                ConnectGhlFormFieldsWidget(
                  apiKeyController: _apiKeyController,
                  locationIdController: _locationIdController,
                ),
                SizedBox(height: 24.h),
                ConnectGhlSaveButtonWidget(
                  apiKeyController: _apiKeyController,
                  locationIdController: _locationIdController,
                ),
                ConnectGhlDeleteButtonWidget(
                  apiKeyController: _apiKeyController,
                  locationIdController: _locationIdController,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
