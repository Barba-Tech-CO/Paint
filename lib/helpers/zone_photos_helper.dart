import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class ZonePhotosHelper {
  static int getTotalItemCount(List<String> photoUrls, {int maxPhotos = 9}) {
    if (photoUrls.length < maxPhotos) {
      return photoUrls.length + 1; // +1 para o slot de adicionar
    }
    return photoUrls.length; // Sem slot de adicionar quando atingir o máximo
  }

  static Widget buildAddPhotoSlot({
    VoidCallback? onAddPhoto,
    int currentPhotos = 0,
    int maxPhotos = 9,
  }) {
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        width: 104,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: AppColors.addPhotoGradient,
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  static Widget buildPhotoWithDeleteButton({
    required String photoUrl,
    required Future<void> Function()? onDelete,
    bool canDelete = true,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            photoUrl,
            fit: BoxFit.cover,
            width: 104,
            height: 128,
          ),
        ),
        if (canDelete)
          Positioned(
            top: 4,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/icons/delete.png',
                  width: 14,
                  height: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
