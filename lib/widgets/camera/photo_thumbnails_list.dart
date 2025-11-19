import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'photo_thumbnails_builder.dart';

class PhotoThumbnailsList extends StatelessWidget {
  final List<XFile> photos;
  final int maxVisibleThumbnails;

  const PhotoThumbnailsList({
    super.key,
    required this.photos,
    this.maxVisibleThumbnails = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return PhotoThumbnailsBuilder(
      photos: photos,
      maxVisibleThumbnails: maxVisibleThumbnails,
    );
  }
}
