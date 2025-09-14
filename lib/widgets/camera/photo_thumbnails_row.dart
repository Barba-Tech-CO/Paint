import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'photo_thumbnails_list.dart';

class PhotoThumbnailsRow extends StatelessWidget {
  final List<XFile> photos;

  const PhotoThumbnailsRow({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: PhotoThumbnailsList(
        photos: photos,
        maxVisibleThumbnails: 3,
      ),
    );
  }
}
