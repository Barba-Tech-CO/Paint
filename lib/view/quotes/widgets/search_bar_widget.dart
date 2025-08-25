import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  const SearchBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.buttonPrimary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
