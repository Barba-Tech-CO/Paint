// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/model/zones_card_model.dart';
import 'package:paintpro/view/edit_zone/widgets/floor_dimension_widget.dart';
import 'package:paintpro/view/edit_zone/widgets/photos_gallery_widget.dart';
import 'package:paintpro/view/edit_zone/widgets/surface_area_display_widget.dart';
import 'package:paintpro/view/widgets/widgets.dart';

class EditZoneView extends StatefulWidget {
  final ZonesCardModel? zone;

  const EditZoneView({super.key, this.zone});

  @override
  State<EditZoneView> createState() => _EditZoneViewState();
}

class _EditZoneViewState extends State<EditZoneView> {
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
    _initializeData();
  }

  void _initializeData() {
    if (widget.zone != null) {
      final zone = widget.zone!;

      // Parse title
      _zoneTitle = zone.title;

      // Parse floor dimensions from "14' x 16'" format
      final dimensions = zone.floorDimensionValue
          .replaceAll("'", "")
          .split(" x ");
      _width = double.tryParse(dimensions.first) ?? 14.0;
      _length = dimensions.length > 1
          ? (double.tryParse(dimensions.last) ?? 16.0)
          : 16.0;

      // Parse surface areas from "485 sq ft" format
      _walls =
          double.tryParse(zone.areaPaintable.replaceAll(" sq ft", "")) ?? 485.0;
      _ceiling =
          double.tryParse(zone.floorAreaValue.replaceAll(" sq ft", "")) ??
          224.0;
      _trim = 60.0; // Default trim value (could be added to model later)

      // Initialize photos with zone image
      _photos = [zone.image];
    } else {
      // Default values
      _zoneTitle = "New Zone";
      _width = 14.0;
      _length = 16.0;
      _walls = 485.0;
      _ceiling = 224.0;
      _trim = 60.0;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: _zoneTitle,
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
