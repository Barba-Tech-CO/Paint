import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/projects/project_model.dart';

enum HomeState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  // State
  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  // Data
  List<ProjectModel> _recentProjects = [];
  List<ProjectModel> get recentProjects => _recentProjects;

  // Commands (removed for simplicity - using direct method calls)

  // Getters
  bool get isLoading => _state == HomeState.loading;
  bool get hasError => _state == HomeState.error;
  bool get hasProjects => _recentProjects.isNotEmpty;

  HomeViewModel(this._estimateRepository);

  /// Adjust image URL based on environment (development vs production)
  String _adjustImageUrl(String originalUrl) {
    if (!AppConfig.isProduction) {
      // In development, replace production domain with local development domain
      final localBaseUrl = AppConfig.baseUrl.replaceAll('/api', '');
      return originalUrl.replaceAll(
        'https://paintpro.barbatech.company',
        localBaseUrl,
      );
    }
    return originalUrl;
  }

  /// Initialize the home view model
  Future<void> initialize() async {
    try {
      await loadRecentProjects();
    } catch (e) {
      // Handle initialization error silently
    }
  }

  /// Load the 3 most recent projects
  Future<void> loadRecentProjects() async {
    try {
      _setState(HomeState.loading);

      final result = await _estimateRepository.getEstimates(
        limit: 10, // Get more than 3 to ensure we have recent ones
        offset: 0,
      );

      result.when(
        ok: (estimates) {
          // If no estimates found, this might be a new device - the repository should handle sync
          if (estimates.isEmpty) {
            _recentProjects = [];
            _setState(HomeState.loaded);
            return;
          }

          // Filter estimates that have photos
          final estimatesWithPhotos = estimates.where((estimate) {
            final hasPhotos =
                (estimate.photos != null && estimate.photos!.isNotEmpty) ||
                (estimate.photosData != null &&
                    estimate.photosData!.isNotEmpty);
            return hasPhotos;
          }).toList();

          // Map estimates to projects and sort by creation date (most recent first)
          final projects = estimatesWithPhotos
              .map(_mapEstimateToProject)
              .toList();

          projects.sort(
            (a, b) =>
                _parseDate(b.createdDate).compareTo(_parseDate(a.createdDate)),
          );

          // Take only the 3 most recent
          _recentProjects = projects.take(3).toList();
          _setState(HomeState.loaded);
        },
        error: (error) {
          _setState(HomeState.error);
        },
      );
    } catch (e) {
      _setState(HomeState.error);
    }
  }

  /// Map EstimateModel to ProjectModel
  ProjectModel _mapEstimateToProject(EstimateModel estimate) {
    try {
      final created = estimate.createdAt != null
          ? '${estimate.createdAt!.month.toString().padLeft(2, '0')}/${estimate.createdAt!.day.toString().padLeft(2, '0')}/${estimate.createdAt!.year % 100}'
          : '';

      // Get first photo from API - must exist
      String image;
      if (estimate.photosData != null && estimate.photosData!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photosData!.first);
      } else if (estimate.photos != null && estimate.photos!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photos!.first);
      } else {
        throw Exception('No photos found in estimate ${estimate.id}');
      }

      // Count zones from estimate data
      final zonesCount = estimate.zones?.length ?? 0;

      final project = ProjectModel(
        id: int.tryParse(estimate.id ?? '') ?? estimate.hashCode,
        projectName: estimate.projectName ?? 'Estimate',
        personName: estimate.clientName ?? 'No Client',
        zonesCount: zonesCount,
        createdDate: created,
        image: image,
      );

      return project;
    } catch (e) {
      // Re-throw the error instead of returning a default project
      rethrow;
    }
  }

  /// Parse date string to DateTime for comparison
  /// Handles different date formats that might come from the API
  DateTime _parseDate(String dateString) {
    try {
      // Try parsing the formatted date (MM/dd/yy)
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? 2000;
          // Convert 2-digit year to 4-digit (assuming 20xx)
          final fullYear = year < 100 ? 2000 + year : year;
          final result = DateTime(fullYear, month, day);
          return result;
        }
      }

      // Try standard DateTime parsing
      final result = DateTime.parse(dateString);
      return result;
    } catch (e) {
      // If all parsing fails, return epoch time (oldest possible)
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// Get dynamic greeting based on current time
  String getDynamicGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good morning!";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon!";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening!";
    } else {
      return "Good night!";
    }
  }

  /// Refresh recent projects
  Future<void> refresh() async {
    await loadRecentProjects();
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }
}
