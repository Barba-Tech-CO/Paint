import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../model/projects/project_card_model.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/zones/zones_details_content_widget.dart';

class ZonesDetailsView extends StatefulWidget {
  final ProjectCardModel? zone;
  const ZonesDetailsView({super.key, this.zone});

  @override
  State<ZonesDetailsView> createState() => _ZonesDetailsViewState();
}

class _ZonesDetailsViewState extends State<ZonesDetailsView> {
  late final ZoneDetailViewModel _detailViewModel;
  late final ZonesListViewModel _listViewModel;

  @override
  void initState() {
    super.initState();
    _detailViewModel = getIt<ZoneDetailViewModel>();
    _listViewModel = getIt<ZonesListViewModel>();

    // Initialize ViewModels only once (safe for multiple calls)
    _detailViewModel.initialize();
    _listViewModel.initialize();

    // Set current zone
    if (widget.zone != null) {
      _detailViewModel.setCurrentZone(widget.zone!);
    }

    // Setup callbacks for communication with list ViewModel
    _setupViewModelCallbacks();
  }

  @override
  void dispose() {
    // Clear callbacks to prevent memory leaks
    _detailViewModel.onZoneDeleted = null;
    _detailViewModel.onZoneUpdated = null;
    super.dispose();
  }

  void _setupViewModelCallbacks() {
    // When zone is deleted, remove from list and navigate back
    _detailViewModel.onZoneDeleted = (int zoneId) {
      if (mounted) {
        _listViewModel.removeZone(zoneId);
        // Use WidgetsBinding to ensure safe context usage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pop();
          }
        });
      }
    };

    // When zone is updated, update in list
    _detailViewModel.onZoneUpdated = (ProjectCardModel updatedZone) {
      if (mounted) {
        _listViewModel.updateZone(updatedZone);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _detailViewModel,
      builder: (context, _) {
        if (_detailViewModel.currentZone == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Zone was not found.',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          );
        }
        return ZonesDetailsContentWidget(
          viewModel: _detailViewModel,
        );
      },
    );
  }
}
