import 'dart:developer';

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
    log('[HOME] Initializing HomeViewModel...');
    try {
      await loadRecentProjects();
      log('[HOME] HomeViewModel initialized successfully');
    } catch (e) {
      log('[HOME] Error initializing HomeViewModel: $e');
    }
  }

  /// Load the 3 most recent projects
  Future<void> loadRecentProjects() async {
    try {
      log('[HOME] Starting to load recent projects...');
      _setState(HomeState.loading);

      log('[HOME] Calling estimateRepository.getEstimates...');
      final result = await _estimateRepository.getEstimates(
        limit: 10, // Get more than 3 to ensure we have recent ones
        offset: 0,
      );

      log('[HOME] Got result from repository, processing...');
      result.when(
        ok: (estimates) {
          log('[HOME] Success! Got ${estimates.length} estimates');

          // Filter estimates that have photos
          final estimatesWithPhotos = estimates.where((estimate) {
            final hasPhotos =
                (estimate.photos != null && estimate.photos!.isNotEmpty) ||
                (estimate.photosData != null &&
                    estimate.photosData!.isNotEmpty);
            if (!hasPhotos) {
              log('[HOME] Skipping estimate ${estimate.id} - no photos');
            }
            return hasPhotos;
          }).toList();

          log(
            '[HOME] Found ${estimatesWithPhotos.length} estimates with photos',
          );

          // Map estimates to projects and sort by creation date (most recent first)
          log('[HOME] Mapping estimates to projects...');
          final projects = estimatesWithPhotos
              .map(_mapEstimateToProject)
              .toList();

          log('[HOME] Sorting projects by date...');
          projects.sort(
            (a, b) =>
                _parseDate(b.createdDate).compareTo(_parseDate(a.createdDate)),
          );

          // Take only the 3 most recent
          _recentProjects = projects.take(3).toList();
          log('[HOME] Final projects count: ${_recentProjects.length}');
          _setState(HomeState.loaded);
        },
        error: (error) {
          log('[HOME] Error loading estimates: $error');
          _setState(HomeState.error);
        },
      );
    } catch (e) {
      log('[HOME] Exception loading recent projects: $e');
      _setState(HomeState.error);
    }
  }

  /// Map EstimateModel to ProjectModel
  ProjectModel _mapEstimateToProject(EstimateModel estimate) {
    try {
      log('[HOME] Mapping estimate: ${estimate.id}');

      final created = estimate.createdAt != null
          ? '${estimate.createdAt!.month.toString().padLeft(2, '0')}/${estimate.createdAt!.day.toString().padLeft(2, '0')}/${estimate.createdAt!.year % 100}'
          : '';

      log('[HOME] Created date: $created');

      // Get first photo from API - must exist
      String image;
      if (estimate.photosData != null && estimate.photosData!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photosData!.first);
        log('[HOME] Using photo from photosData: $image');
      } else if (estimate.photos != null && estimate.photos!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photos!.first);
        log('[HOME] Using photo from photos: $image');
      } else {
        log('[HOME] ERROR: No photos found in estimate ${estimate.id}');
        throw Exception('No photos found in estimate ${estimate.id}');
      }

      // Count zones from estimate data
      final zonesCount = estimate.zones?.length ?? 0;
      log('[HOME] Zones count: $zonesCount');

      // Debug log to check client name
      log('[HOME] Estimate ID: ${estimate.id}');
      log('[HOME] Project Name: "${estimate.projectName}"');
      log('[HOME] Client Name: "${estimate.clientName}"');
      log('[HOME] Contact ID: "${estimate.contactId}"');
      log('[HOME] Client Name is null: ${estimate.clientName == null}');
      log(
        '[HOME] Client Name is empty: ${estimate.clientName?.isEmpty ?? true}',
      );

      final project = ProjectModel(
        id: int.tryParse(estimate.id ?? '') ?? estimate.hashCode,
        projectName: estimate.projectName ?? 'Estimate',
        personName: estimate.clientName ?? 'No Client',
        zonesCount: zonesCount,
        createdDate: created,
        image: image,
      );

      log(
        '[HOME] Created project: ${project.projectName} - ${project.personName}',
      );
      return project;
    } catch (e) {
      log('[HOME] Error mapping estimate to project: $e');
      // Re-throw the error instead of returning a default project
      rethrow;
    }
  }

  /// Parse date string to DateTime for comparison
  /// Handles different date formats that might come from the API
  DateTime _parseDate(String dateString) {
    try {
      log('[HOME] Parsing date: "$dateString"');

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
          log('[HOME] Parsed date successfully: $result');
          return result;
        }
      }

      // Try standard DateTime parsing
      final result = DateTime.parse(dateString);
      log('[HOME] Parsed date with DateTime.parse: $result');
      return result;
    } catch (e) {
      log('[HOME] Error parsing date "$dateString": $e');
      // If all parsing fails, return epoch time (oldest possible)
      return DateTime.fromMillisecondsSinceEpoch(0);
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

  @override
  void dispose() {
    super.dispose();
  }
}
