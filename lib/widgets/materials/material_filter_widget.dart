import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/material_models/material_model.dart' as model;
import '../../config/app_colors.dart';
import 'drop_down_filter_widget.dart';

class MaterialFilterWidget extends StatefulWidget {
  final model.MaterialFilter currentFilter;
  final List<String> availableBrands;
  final Function(model.MaterialFilter) onFilterChanged;
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
  late model.MaterialFilter _currentFilter;

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
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
              const Text(
                'Filter by:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_currentFilter.hasFilters)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = model.MaterialFilter();
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
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),

          // Ambient Filter (Type)
          DropDownFilterWidget<model.MaterialType>(
            label: 'Ambient',
            value: _currentFilter.type,
            items: model.MaterialType.values,
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(type: value);
              });
            },
            itemBuilder: (type) => Text(type.displayName),
          ),
          const SizedBox(height: 16),

          // Finish Filter
          DropDownFilterWidget<model.MaterialFinish>(
            label: 'Finish',
            value: _currentFilter.finish,
            items: model.MaterialFinish.values,
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(finish: value);
              });
            },
            itemBuilder: (finish) => Text(finish.displayName),
          ),
          const SizedBox(height: 16),

          // Quality Filter
          const Text(
            'Quality',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: model.MaterialQuality.values.map((quality) {
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
          const SizedBox(height: 24),

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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
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
