// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:paintpro/view/edit_zone/widgets/floor_dimension_widget.dart';
import 'package:paintpro/view/edit_zone/widgets/photos_gallery_widget.dart';
import 'package:paintpro/view/edit_zone/widgets/surface_area_display_widget.dart';
import 'package:paintpro/view/widgets/widgets.dart';

class EditZoneView extends StatefulWidget {
  const EditZoneView({super.key});

  @override
  State<EditZoneView> createState() => _EditZoneViewState();
}

class _EditZoneViewState extends State<EditZoneView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'teste'),
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
                width: 14,
                length: 16,
              ),
              SizedBox(height: 48),
              SurfaceAreaDisplayWidget(),
              SizedBox(height: 32),
              PhotosGalleryWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
