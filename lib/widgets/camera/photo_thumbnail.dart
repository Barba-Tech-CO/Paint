import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'photo_count_badge.dart';

class PhotoThumbnail extends StatelessWidget {
  final XFile photo;
  final bool shouldShowBadge;
  final int extraCount;

  const PhotoThumbnail({
    super.key,
    required this.photo,
    this.shouldShowBadge = false,
    this.extraCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Thumbnail image
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),

        // Badge for extra photos count
        if (shouldShowBadge && extraCount > 0) ...[
          const SizedBox(width: 16),
          PhotoCountBadge(extraCount: extraCount),
        ],
      ],
    );
  }
}
