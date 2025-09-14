import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'photo_thumbnail.dart';

class PhotoThumbnailsBuilder extends StatelessWidget {
  final List<XFile> photos;
  final int maxVisibleThumbnails;

  const PhotoThumbnailsBuilder({
    super.key,
    required this.photos,
    this.maxVisibleThumbnails = 3,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> thumbnails = [];

    // Calculate how many thumbnails to show
    final int visibleCount = photos.length > maxVisibleThumbnails
        ? maxVisibleThumbnails
        : photos.length;

    // Add thumbnails
    for (int i = 0; i < visibleCount; i++) {
      final bool isLast = i == visibleCount - 1;
      final bool shouldShowBadge =
          photos.length > maxVisibleThumbnails && isLast;

      thumbnails.add(
        PhotoThumbnail(
          photo: photos[i],
          shouldShowBadge: shouldShowBadge,
          extraCount: shouldShowBadge
              ? photos.length - maxVisibleThumbnails
              : 0,
        ),
      );

      // Add spacing between thumbnails
      if (i < visibleCount - 1) {
        thumbnails.add(
          const SizedBox(width: 8),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: thumbnails,
    );
  }
}
