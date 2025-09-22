import '../../config/app_config.dart';
import '../../domain/repository/estimate_repository.dart';
import '../../domain/repository/offline_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/projects/project_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';
import '../../service/sync_service.dart';

class ProjectOperationsUseCase {
  final IEstimateRepository _estimateRepository;
  final IOfflineRepository _offlineRepository;
  final SyncService _syncService;
  final AppLogger _logger;

  ProjectOperationsUseCase(
    this._estimateRepository,
    this._offlineRepository,
    this._syncService,
    this._logger,
  );

  /// Loads projects by fetching estimates from the repository
  Future<Result<List<ProjectModel>>> loadProjects() async {
    try {
      // First try to load from offline storage
      final offlineResult = await _offlineRepository.getAllProjects();
      if (offlineResult is Ok<List<ProjectModel>>) {
        final offlineProjects = offlineResult.asOk.value;
        _logger.info(
          'ProjectOperationsUseCase: Loaded ${offlineProjects.length} projects from offline storage',
        );

        // If we have offline data, return it immediately and sync in background
        if (offlineProjects.isNotEmpty) {
          // Try to sync with API in background
          _syncService.fullSync();
          return Result.ok(offlineProjects);
        }
      } else {
        _logger.error(
          'ProjectOperationsUseCase: Error loading from offline storage: ${offlineResult.asError.error}',
        );
      }

      // If no offline data, try smart sync (which will pull from API if local storage is empty)
      _logger.info('No local projects found, attempting smart sync...');
      final syncResult = await _syncService.smartSync();

      if (syncResult is Ok) {
        // After sync, try to load from offline storage again
        final updatedOfflineResult = await _offlineRepository.getAllProjects();
        if (updatedOfflineResult is Ok<List<ProjectModel>>) {
          final updatedProjects = updatedOfflineResult.asOk.value;
          _logger.info(
            'After smart sync, loaded ${updatedProjects.length} projects from offline storage',
          );
          return Result.ok(updatedProjects);
        }
      } else {
        _logger.error('Smart sync failed: ${syncResult.asError.error}');
      }

      // Fallback: try API directly
      final result = await _estimateRepository.getEstimates(
        limit: 50,
        offset: 0,
      );

      if (result is Ok<List<EstimateModel>>) {
        final estimates = result.asOk.value;
        final projects = estimates.map(_mapEstimateToProject).toList();

        // Save to offline storage
        for (final estimate in estimates) {
          await _offlineRepository.saveEstimate(estimate);
        }

        return Result.ok(projects);
      } else {
        _logger.error(
          'Error loading projects from API: ${result.asError.error}',
          result.asError.error,
        );

        // Return offline data even if API failed
        if (offlineResult is Ok<List<ProjectModel>>) {
          return Result.ok(offlineResult.asOk.value);
        }

        return Result.error(
          Exception('Failed to load projects'),
        );
      }
    } catch (e) {
      _logger.error('Error loading projects: $e', e);

      // Try to return offline data as fallback
      final offlineResult = await _offlineRepository.getAllProjects();
      if (offlineResult is Ok<List<ProjectModel>>) {
        return Result.ok(offlineResult.asOk.value);
      }

      return Result.error(
        Exception('Failed to load projects'),
      );
    }
  }

  /// Creates a new project by creating an estimate
  Future<Result<ProjectModel>> createProject(ProjectModel project) async {
    try {
      // Always save to offline storage first
      final offlineResult = await _offlineRepository.saveProject(project);
      if (offlineResult is Error) {
        _logger.error(
          'Failed to save project offline: ${offlineResult.asError.error}',
        );
        return Result.error(
          Exception('Failed to save project offline'),
        );
      }

      final projectId = offlineResult.asOk.value;
      final projectWithId = project.copyWith(
        id: int.tryParse(projectId) ?? project.id,
      );

      // Try to sync with API if online
      final isOnline = await _syncService.isOnline();
      if (isOnline) {
        try {
          final estimate = EstimateModel(
            id: projectWithId.id.toString(),
            projectName: projectWithId.projectName,
            clientName: projectWithId.personName,
            status: EstimateStatus.draft,
            createdAt: DateTime.now(),
          );
          final result = await _estimateRepository.createEstimateMultipart(
            estimate,
          );

          if (result is Ok<EstimateModel>) {
            final newEstimate = result.asOk.value;
            final newProject = _mapEstimateToProject(newEstimate);

            // Update offline storage with API response
            await _offlineRepository.updateEstimate(newEstimate);
            await _offlineRepository.markEstimateAsSynced(newEstimate.id!);

            _logger.info(
              'Project created and synced with API: ${newProject.id}',
            );
            return Result.ok(newProject);
          } else {
            _logger.warning(
              'Failed to sync project with API, saved offline only: ${result.asError.error}',
            );

            // Add to pending operations for later sync
            final estimate = EstimateModel(
              id: projectWithId.id.toString(),
              projectName: projectWithId.projectName,
              clientName: projectWithId.personName,
              status: EstimateStatus.draft,
              createdAt: DateTime.now(),
            );
            await _offlineRepository.addPendingOperation(
              'create_estimate',
              estimate.toJson(),
            );
          }
        } catch (e) {
          _logger.warning(
            'Error syncing project with API, saved offline only: $e',
          );

          // Add to pending operations for later sync
          final estimate = EstimateModel(
            id: projectWithId.id.toString(),
            projectName: projectWithId.projectName,
            clientName: projectWithId.personName,
            status: EstimateStatus.draft,
            createdAt: DateTime.now(),
          );
          await _offlineRepository.addPendingOperation(
            'create_estimate',
            estimate.toJson(),
          );
        }
      } else {
        _logger.info('Device offline, project saved locally only');

        // Add to pending operations for later sync
        final estimate = EstimateModel(
          id: projectWithId.id.toString(),
          projectName: projectWithId.projectName,
          clientName: projectWithId.personName,
          status: EstimateStatus.draft,
          createdAt: DateTime.now(),
        );
        await _offlineRepository.addPendingOperation(
          'create_estimate',
          estimate.toJson(),
        );
      }

      return Result.ok(projectWithId);
    } catch (e) {
      _logger.error('Error creating project: $e', e);
      return Result.error(
        Exception('Failed to create project'),
      );
    }
  }

  /// Updates an existing project by updating the estimate
  Future<Result<ProjectModel>> updateProject(ProjectModel project) async {
    try {
      // Always update offline storage first
      final offlineResult = await _offlineRepository.updateProject(project);
      if (offlineResult is Error) {
        _logger.error(
          'Failed to update project offline: ${offlineResult.asError.error}',
        );
        return Result.error(
          Exception('Failed to update project offline'),
        );
      }

      // Try to sync with API if online
      final isOnline = await _syncService.isOnline();
      if (isOnline) {
        try {
          final estimateData = _mapProjectToEstimateData(project);
          final result = await _estimateRepository.updateEstimate(
            project.id.toString(),
            estimateData,
          );

          if (result is Ok<EstimateModel>) {
            final updatedEstimate = result.asOk.value;
            final updatedProject = _mapEstimateToProject(updatedEstimate);

            // Update offline storage with API response
            await _offlineRepository.updateEstimate(updatedEstimate);
            await _offlineRepository.markEstimateAsSynced(updatedEstimate.id!);

            _logger.info(
              'Project updated and synced with API: ${updatedProject.id}',
            );
            return Result.ok(updatedProject);
          } else {
            _logger.warning(
              'Failed to sync project update with API: ${result.asError.error}',
            );

            // Add to pending operations for later sync
            await _offlineRepository.addPendingOperation(
              'update_estimate',
              estimateData,
            );
          }
        } catch (e) {
          _logger.warning('Error syncing project update with API: $e');

          // Add to pending operations for later sync
          await _offlineRepository.addPendingOperation(
            'update_estimate',
            _mapProjectToEstimateData(project),
          );
        }
      } else {
        _logger.info('Device offline, project updated locally only');

        // Add to pending operations for later sync
        await _offlineRepository.addPendingOperation(
          'update_estimate',
          _mapProjectToEstimateData(project),
        );
      }

      return Result.ok(project);
    } catch (e) {
      _logger.error('Error updating project: $e', e);
      return Result.error(
        Exception('Failed to update project'),
      );
    }
  }

  /// Deletes a project by deleting the estimate
  Future<Result<bool>> deleteProject(String projectId) async {
    try {
      // Always delete from offline storage first
      final offlineResult = await _offlineRepository.deleteProject(projectId);
      if (offlineResult is Error) {
        _logger.error(
          'Failed to delete project offline: ${offlineResult.asError.error}',
        );
        return Result.error(
          Exception('Failed to delete project offline'),
        );
      }

      // Try to sync with API if online
      final isOnline = await _syncService.isOnline();
      if (isOnline) {
        try {
          final result = await _estimateRepository.deleteEstimate(projectId);

          if (result is Ok<bool>) {
            _logger.info('Project deleted and synced with API: $projectId');
            return Result.ok(result.asOk.value);
          } else {
            _logger.warning(
              'Failed to sync project deletion with API: ${result.asError.error}',
            );

            // Add to pending operations for later sync
            await _offlineRepository.addPendingOperation(
              'delete_estimate',
              {'id': projectId},
            );
          }
        } catch (e) {
          _logger.warning('Error syncing project deletion with API: $e');

          // Add to pending operations for later sync
          await _offlineRepository.addPendingOperation(
            'delete_estimate',
            {'id': projectId},
          );
        }
      } else {
        _logger.info('Device offline, project deleted locally only');

        // Add to pending operations for later sync
        await _offlineRepository.addPendingOperation(
          'delete_estimate',
          {'id': projectId},
        );
      }

      return Result.ok(true);
    } catch (e) {
      _logger.error('Error deleting project: $e', e);
      return Result.error(
        Exception('Failed to delete project'),
      );
    }
  }

  /// Renames a project by updating only the project name in the estimate
  Future<Result<ProjectModel>> renameProject(
    String projectId,
    String newName,
  ) async {
    try {
      // Get current project from offline storage
      final projectsResult = await _offlineRepository.getAllProjects();
      if (projectsResult is Error) {
        return Result.error(
          Exception('Failed to get project from offline storage'),
        );
      }

      final projects = projectsResult.asOk.value;
      final project = projects.firstWhere(
        (p) => p.id.toString() == projectId,
        orElse: () => throw Exception('Project not found'),
      );

      final updatedProject = project.copyWith(projectName: newName);

      // Always update offline storage first
      final offlineResult = await _offlineRepository.updateProject(
        updatedProject,
      );
      if (offlineResult is Error) {
        _logger.error(
          'Failed to rename project offline: ${offlineResult.asError.error}',
        );
        return Result.error(
          Exception('Failed to rename project offline'),
        );
      }

      // Try to sync with API if online
      final isOnline = await _syncService.isOnline();
      if (isOnline) {
        try {
          final estimateData = {
            'project_name': newName,
          };

          final result = await _estimateRepository.updateEstimate(
            projectId,
            estimateData,
          );

          if (result is Ok<EstimateModel>) {
            final updatedEstimate = result.asOk.value;
            final syncedProject = _mapEstimateToProject(updatedEstimate);

            // Update offline storage with API response
            await _offlineRepository.updateEstimate(updatedEstimate);
            await _offlineRepository.markEstimateAsSynced(updatedEstimate.id!);

            _logger.info('Project renamed and synced with API: $projectId');
            return Result.ok(syncedProject);
          } else {
            _logger.warning(
              'Failed to sync project rename with API: ${result.asError.error}',
            );

            // Add to pending operations for later sync
            await _offlineRepository.addPendingOperation(
              'update_estimate',
              estimateData,
            );
          }
        } catch (e) {
          _logger.warning('Error syncing project rename with API: $e');

          // Add to pending operations for later sync
          await _offlineRepository.addPendingOperation(
            'update_estimate',
            {'project_name': newName},
          );
        }
      } else {
        _logger.info('Device offline, project renamed locally only');

        // Add to pending operations for later sync
        await _offlineRepository.addPendingOperation(
          'update_estimate',
          {'project_name': newName},
        );
      }

      return Result.ok(updatedProject);
    } catch (e) {
      _logger.error('Error renaming project: $e', e);
      return Result.error(
        Exception('Failed to rename project'),
      );
    }
  }

  /// Maps an EstimateModel to a ProjectModel
  ProjectModel _mapEstimateToProject(EstimateModel e) {
    final created = e.createdAt != null
        ? '${e.createdAt!.day.toString().padLeft(2, '0')}/${e.createdAt!.month.toString().padLeft(2, '0')}/${e.createdAt!.year % 100}'
        : '';

    // Get first photo from API
    String image;
    if (e.photosData != null && e.photosData!.isNotEmpty) {
      image = _adjustImageUrl(e.photosData!.first);
    } else if (e.photos != null && e.photos!.isNotEmpty) {
      image = _adjustImageUrl(e.photos!.first);
    } else {
      // No fallback image - throw error if no photos available
      throw Exception('No photos found in estimate ${e.id}');
    }

    return ProjectModel(
      id: int.tryParse(e.id ?? '') ?? e.hashCode,
      projectName: e.projectName ?? 'Estimate',
      personName: e.clientName ?? '',
      zonesCount: e.zones?.length ?? 0,
      createdDate: created,
      image: image,
    );
  }

  /// Maps a ProjectModel to estimate data for API calls
  Map<String, dynamic> _mapProjectToEstimateData(ProjectModel project) {
    return {
      'project_name': project.projectName,
      'client_name': project.personName,
      'zones': List.generate(
        project.zonesCount,
        (index) => {
          'name': 'Zone ${index + 1}',
          'area': 0.0,
          'materials': [],
        },
      ),
      'photos': project.image.isNotEmpty ? [project.image] : [],
    };
  }

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
}
