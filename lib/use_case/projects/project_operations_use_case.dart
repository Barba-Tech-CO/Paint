import '../../config/app_config.dart';
import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/projects/project_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ProjectOperationsUseCase {
  final IEstimateRepository _estimateRepository;
  final AppLogger _logger;

  ProjectOperationsUseCase(
    this._estimateRepository,
    this._logger,
  );

  /// Loads projects by fetching estimates from the repository (EXACTLY same logic as Home)
  Future<Result<List<ProjectModel>>> loadProjects() async {
    try {
      // Use the same logic as Home - get estimates directly from repository
      final result = await _estimateRepository.getEstimates(
        limit: 100, // Get all projects (unlike Home which gets only 3)
        offset: 0,
      );

      if (result is Ok<List<EstimateModel>>) {
        final estimates = result.asOk.value;

        // If no estimates found, this might be a new device - the repository should handle sync
        if (estimates.isEmpty) {
          return Result.ok(<ProjectModel>[]);
        }

        // Map estimates to projects (same as Home)
        final projects = estimates.map(_mapEstimateToProject).toList();

        // Sort by creation date (most recent first) - same as Home
        projects.sort(
          (a, b) => _parseDate(b.createdDate).compareTo(
            _parseDate(a.createdDate),
          ),
        );

        return Result.ok(projects);
      } else {
        _logger.error(
          'ProjectOperationsUseCase: Error loading from estimate repository: ${result.asError.error}',
        );
        return Result.error(
          Exception('Failed to load projects from estimate repository'),
        );
      }
    } catch (e) {
      _logger.error('Error in loadProjects: $e', e);
      return Result.error(
        Exception('Failed to load projects'),
      );
    }
  }

  /// Adjust image URL based on environment (development vs production) - EXACTLY same as Home
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

  /// Map EstimateModel to ProjectModel - EXACTLY same as Home
  ProjectModel _mapEstimateToProject(EstimateModel estimate) {
    try {
      final created = estimate.createdAt != null
          ? '${estimate.createdAt!.month.toString().padLeft(2, '0')}/${estimate.createdAt!.day.toString().padLeft(2, '0')}/${estimate.createdAt!.year % 100}'
          : '';

      // Debug: log what photos are available
      _logger.error('Estimate ${estimate.id} - photos: ${estimate.photos}, photosData: ${estimate.photosData}');
      if (estimate.zones != null) {
        _logger.error('Estimate ${estimate.id} - zones count: ${estimate.zones!.length}');
      }

      // Get first photo from API - EXACTLY same as Home
      String image = '';
      if (estimate.photosData != null && estimate.photosData!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photosData!.first);
      } else if (estimate.photos != null && estimate.photos!.isNotEmpty) {
        image = _adjustImageUrl(estimate.photos!.first);
      } else if (estimate.zones != null && estimate.zones!.isNotEmpty) {
        // Try to get photo from zones as fallback
        bool foundPhoto = false;
        for (final zone in estimate.zones!) {
          if (zone.data.isNotEmpty && zone.data.first.photoPaths.isNotEmpty) {
            image = _adjustImageUrl(zone.data.first.photoPaths.first);
            _logger.error('Using zone photo: $image');
            foundPhoto = true;
            break;
          }
        }
        if (!foundPhoto) {
          throw Exception('No photos found in estimate ${estimate.id}');
        }
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

  /// Parse date string to DateTime for comparison - EXACTLY same as Home
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

  /// Create a new project (estimate)
  Future<Result<ProjectModel>> createProject(ProjectModel project) async {
    try {
      // Projects are estimates, so we need to create an estimate
      // This method should probably not be used since projects are created from estimates
      // But if needed, we'd call _estimateRepository.createEstimate()
      throw UnimplementedError(
        'Creating projects directly is not supported. Projects are created from estimates.',
      );
    } catch (e) {
      _logger.error('Error creating project: $e', e);
      return Result.error(
        Exception('Failed to create project'),
      );
    }
  }

  /// Update a project (estimate)
  Future<Result<ProjectModel>> updateProject(ProjectModel project) async {
    try {
      // Projects are estimates, so we need to update an estimate
      // This would require converting ProjectModel back to EstimateModel
      throw UnimplementedError(
        'Updating projects directly is not supported. Update estimates instead.',
      );
    } catch (e) {
      _logger.error('Error updating project: $e', e);
      return Result.error(
        Exception('Failed to update project'),
      );
    }
  }

  /// Delete a project (estimate)
  Future<Result<void>> deleteProject(String projectId) async {
    try {
      // Projects are estimates, so we need to delete an estimate
      final result = await _estimateRepository.deleteEstimate(projectId);
      if (result is Ok) {
        return Result.ok(null);
      } else {
        _logger.error('Error deleting project: ${result.asError.error}');
        return Result.error(
          Exception('Failed to delete project'),
        );
      }
    } catch (e) {
      _logger.error('Error deleting project: $e', e);
      return Result.error(
        Exception('Failed to delete project'),
      );
    }
  }

  /// Rename a project (estimate)
  Future<Result<ProjectModel>> renameProject(
    String projectId,
    String newName,
  ) async {
    try {
      // Projects are estimates, so we need to update the estimate's project name
      // This would require getting the estimate, updating the name, and saving it back
      throw UnimplementedError(
        'Renaming projects directly is not supported. Update estimates instead.',
      );
    } catch (e) {
      _logger.error('Error renaming project: $e', e);
      return Result.error(
        Exception('Failed to rename project'),
      );
    }
  }
}
