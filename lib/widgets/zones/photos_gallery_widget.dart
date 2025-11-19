import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotosGalleryWidget extends StatelessWidget {
  final List<String>? photos;
  final VoidCallback? onAddPhoto;
  final Function(int index)? onRemovePhoto;

  const PhotosGalleryWidget({
    super.key,
    this.photos,
    this.onAddPhoto,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final photoList = photos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1,
          ),
          itemCount: photoList.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            if (index == photoList.length) {
              // Add photo button
              return GestureDetector(
                onTap: onAddPhoto,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2.w,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 40.sp,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            // Photo item
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    image: DecorationImage(
                      image: FileImage(
                        File(photoList[index]),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Delete button
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () => onRemovePhoto?.call(index),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
