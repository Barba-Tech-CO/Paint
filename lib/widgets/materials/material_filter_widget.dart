import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../model/material_models/material_filter.dart';
import '../../model/material_models/material_enums.dart' as enums;
import '../../config/app_colors.dart';
import 'drop_down_filter_widget.dart';

class MaterialFilterWidget extends StatefulWidget {
  final MaterialFilter currentFilter;
  final List<String> availableBrands;
  final Function(MaterialFilter) onFilterChanged;
  final VoidCallback? onClearFilters;

  const MaterialFilterWidget({
    super.key,
    required this.currentFilter,
    required this.availableBrands,
    required this.onFilterChanged,
    this.onClearFilters,
  });

  @override
  State<MaterialFilterWidget> createState() => _MaterialFilterWidgetState();
}

class _MaterialFilterWidgetState extends State<MaterialFilterWidget> {
  late MaterialFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.currentFilter;
  }

  @override
  void didUpdateWidget(MaterialFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilter != widget.currentFilter) {
      _currentFilter = widget.currentFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by:',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_currentFilter.hasFilters)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = MaterialFilter();
                        });
                        widget.onFilterChanged(_currentFilter);
                        widget.onClearFilters?.call();
                      },
                      child: const Text('Reset All'),
                    ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Brand Filter
          DropDownFilterWidget<String>(
            label: 'Brand',
            value: _currentFilter.brand,
            items: widget.availableBrands,
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(brand: value);
              });
            },
            itemBuilder: (brand) => Text(brand),
          ),
          SizedBox(height: 16.h),

          // Ambient Filter (Type)
          DropDownFilterWidget<enums.MaterialType>(
            label: 'Ambient',
            value: _currentFilter.type,
            items: enums.MaterialType.values,
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(type: value);
              });
            },
            itemBuilder: (type) => Text(type.displayName),
          ),
          SizedBox(height: 16.h),

          // Finish Filter
          DropDownFilterWidget<enums.MaterialFinish>(
            label: 'Finish',
            value: _currentFilter.finish,
            items: enums.MaterialFinish.values,
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(finish: value);
              });
            },
            itemBuilder: (finish) => Text(finish.displayName),
          ),
          SizedBox(height: 16.h),

          // Quality Filter
          Text(
            'Quality',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: enums.MaterialQuality.values.map((quality) {
              final isSelected = _currentFilter.quality == quality;
              return FilterChip(
                label: Text(quality.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      quality: selected ? quality : null,
                    );
                  });
                },
                selectedColor: AppColors.primary.withAlpha(3),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_currentFilter);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
