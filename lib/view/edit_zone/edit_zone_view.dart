import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../model/projects/project_card_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/buttons/paint_pro_delete_button.dart';
import '../../widgets/zones/floor_dimension_widget.dart';
import '../../widgets/zones/photos_gallery_widget.dart';
import '../../widgets/zones/surface_area_display_widget.dart';

class EditZoneView extends StatefulWidget {
  final ProjectCardModel? zone;

  const EditZoneView({super.key, this.zone});

  @override
  State<EditZoneView> createState() => _EditZoneViewState();
}

class _EditZoneViewState extends State<EditZoneView> {
  late final ZoneDetailViewModel _viewModel;
  late String _zoneTitle;
  late double _width;
  late double _length;
  late double _walls;
  late double _ceiling;
  late double _trim;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ZoneDetailViewModel>();
    _viewModel.initialize();

    if (widget.zone != null) {
      _viewModel.setCurrentZone(widget.zone!);
    }

    // Setup callbacks for delete action
    _setupViewModelCallbacks();

    _initializeData();
  }

  void _setupViewModelCallbacks() {
    // When zone is deleted, navigate back automatically
    _viewModel.onZoneDeleted = (int zoneId) {
      if (mounted) {
        // Also notify the list ViewModel to remove the zone
        try {
          final listViewModel = getIt<ZonesListViewModel>();
          listViewModel.removeZone(zoneId);
        } catch (e) {
          debugPrint('Error notifying list ViewModel: $e');
        }

        // Use WidgetsBinding to ensure safe context usage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pop();
          }
        });
      }
    };

    // When zone is updated, we could refresh the data here if needed
    _viewModel.onZoneUpdated = (ProjectCardModel updatedZone) {
      if (mounted) {
        // Also notify the list ViewModel
        try {
          final listViewModel = getIt<ZonesListViewModel>();
          listViewModel.updateZone(updatedZone);
        } catch (e) {
          debugPrint('Error notifying list ViewModel: $e');
        }

        setState(() {
          // Update local data with new zone info
          _zoneTitle = updatedZone.title;
          // Could update other fields if needed
        });
      }
    };
  }

  void _initializeData() {
    if (widget.zone != null) {
      final zone = widget.zone!;
      _zoneTitle = zone.title;

      // Parse floor dimensions from "14' x 16'" format
      final dimensions = zone.floorDimensionValue
          .replaceAll("'", "")
          .split(" x ");
      _width = double.tryParse(dimensions.first) ?? 0.0;
      _length = dimensions.length > 1
          ? (double.tryParse(dimensions.last) ?? 0.0)
          : 0.0;

      // Parse surface areas from zone fields
      _walls =
          double.tryParse(zone.areaPaintable.replaceAll(" sq ft", "")) ?? 0.0;
      _ceiling = zone.ceilingArea != null
          ? double.tryParse(zone.ceilingArea!.replaceAll(" sq ft", "")) ?? 0.0
          : double.tryParse(zone.floorAreaValue.replaceAll(" sq ft", "")) ??
                0.0;
      _trim = zone.trimLength != null
          ? double.tryParse(zone.trimLength!.replaceAll(" linear ft", "")) ??
                0.0
          : 0.0;

      // Initialize photos with zone image (se disponível)
      _photos = zone.image.isNotEmpty ? [zone.image] : [];
    } else {
      // Sem mocks: valores vazios/iniciais
      _zoneTitle = '';
      _width = 0.0;
      _length = 0.0;
      _walls = 0.0;
      _ceiling = 0.0;
      _trim = 0.0;
      _photos = [];
    }
  }

  void _onDimensionChanged(double width, double length) {
    setState(() {
      _width = width;
      _length = length;
      // Recalculate surface areas if needed
      _ceiling = width * length;
    });
  }

  @override
  void dispose() {
    // Clear callbacks to prevent memory leaks
    _viewModel.onZoneDeleted = null;
    _viewModel.onZoneUpdated = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: _zoneTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          PaintProDeleteButton(
            viewModel: _viewModel,
            logger: getIt<AppLogger>(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                'Room Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              FloorDimensionWidget(
                width: _width,
                length: _length,
                onDimensionChanged: _onDimensionChanged,
              ),
              SizedBox(height: 48),
              SurfaceAreaDisplayWidget(
                walls: _walls,
                ceiling: _ceiling,
                trim: _trim,
              ),
              SizedBox(height: 32),
              PhotosGalleryWidget(
                photos: _photos,
              ),
              SizedBox(height: 32),
              // Save button
              PaintProButton(
                text: 'Save',
                onPressed: () => context.pop(context),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
