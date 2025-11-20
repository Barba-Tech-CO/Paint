import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../viewmodel/zones/zone_detail_viewmodel.dart';

class ZonePhotosWidget extends StatelessWidget {
  final List<String> photoUrls;
  final VoidCallback? onAddPhoto;
  final Future<void> Function(int index)? onDeletePhoto;
  final int minPhotos;
  final int maxPhotos;

  const ZonePhotosWidget({
    super.key,
    required this.photoUrls,
    this.onAddPhoto,
    this.onDeletePhoto,
    this.minPhotos = 3,
    this.maxPhotos = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.w,
            crossAxisSpacing: 8.w,
          ),
          itemCount: ZoneDetailViewModel.getTotalItemCount(
            photoUrls,
            maxPhotos: maxPhotos,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < photoUrls.length) {
              // Exibir foto existente com ícone de delete
              final url = photoUrls[index];
              final canDelete = photoUrls.length > minPhotos;
              return ZoneDetailViewModel.buildPhotoWithDeleteButton(
                photoUrl: url,
                onDelete: canDelete
                    ? () async => await onDeletePhoto?.call(index)
                    : null,
                canDelete: canDelete,
              );
            } else {
              // Exibir slot de adicionar foto
              return ZoneDetailViewModel.buildAddPhotoSlot(
                onAddPhoto: onAddPhoto,
                currentPhotos: photoUrls.length,
                maxPhotos: maxPhotos,
              );
            }
          },
        ),
      ],
    );
  }
}
