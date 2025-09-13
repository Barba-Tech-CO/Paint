import 'dart:async';

import 'package:flutter/material.dart';

import '../../model/contacts/contact_model.dart';

class ContactsHelper {
  /// Converts ContactModel to Map for display purposes
  static Map<String, String> convertContactModelToMap(ContactModel contact) {
    return {
      'name': contact.name,
      'phone': contact.phone,
      'address': '${contact.address}, ${contact.city}, ${contact.country}'
          .replaceAll(RegExp(r',\s*,'), ',')
          .replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
    };
  }

  /// Creates a debounced search function
  static void createDebouncedSearch({
    required TextEditingController searchController,
    required Function(String) onSearchChanged,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Timer? debounceTimer;

    searchController.addListener(() {
      debounceTimer?.cancel();
      debounceTimer = Timer(delay, () {
        final query = searchController.text.trim();
        onSearchChanged(query);
      });
    });
  }

  /// Handles keyboard dismissal when tapping outside
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Gets error widget for contacts view
  static Widget getErrorWidget({
    required String? errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Unknown error',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  /// Gets loading widget
  static Widget getLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Gets empty state widget
  static Widget getEmptyStateWidget({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
    required VoidCallback onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: Colors.blue, // This should be AppColors.primary in actual usage
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400, // This should be calculated based on screen size
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contacts_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
