import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../model/projects/project_model.dart';
import '../service/http_service.dart';
import '../utils/result/result.dart';
import 'project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final HttpService _httpService;
  static const String _baseUrl = '/estimates';

  ProjectRepositoryImpl(this._httpService);

  @override
  Future<Result<List<ProjectModel>>> getProjects({
    int? limit,
    int? offset,
    String? status,
    String? clientName,
    String? projectType,
    String? search,
  }) async {
    try {
      log('[ProjectRepository] Getting projects...');

      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) queryParams['status'] = status;
      if (clientName != null) queryParams['client_name'] = clientName;
      if (projectType != null) queryParams['project_type'] = projectType;
      if (search != null) queryParams['search'] = search;

      final response = await _httpService.get(
        '$_baseUrl/estimates',
        queryParameters: queryParams,
      );

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is List) {
          final List<dynamic> projectsJson = data['data'];
          final projects = projectsJson
              .map((json) => _mapEstimateToProject(json))
              .toList();

          log(
            '[ProjectRepository] Successfully loaded ${projects.length} projects',
          );
          return Result.ok(projects);
        } else if (data is List) {
          final projects = data
              .map((json) => _mapEstimateToProject(json))
              .toList();

          log(
            '[ProjectRepository] Successfully loaded ${projects.length} projects',
          );
          return Result.ok(projects);
        } else {
          log(
            '[ProjectRepository] Invalid response format: ${data.runtimeType}',
          );
          return Result.error(Exception('Invalid response format'));
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error loading projects';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'loading projects');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error loading projects: $e'));
    }
  }

  @override
  Future<Result<ProjectModel>> getProject(String id) async {
    try {
      log('[ProjectRepository] Getting project with ID: $id');

      final response = await _httpService.get('$_baseUrl/estimates/$id');

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final project = _mapEstimateToProject(data);
          log(
            '[ProjectRepository] Successfully loaded project: ${project.projectName}',
          );
          return Result.ok(project);
        } else {
          log('[ProjectRepository] Invalid response format');
          return Result.error(Exception('Invalid response format'));
        }
      } else {
        final errorMessage = response.data['message'] ?? 'Project not found';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'getting project');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error getting project: $e'));
    }
  }

  @override
  Future<Result<ProjectModel>> createProject({
    required String projectName,
    required String clientName,
    required String projectType,
    required String contact,
    String? additionalNotes,
    String? wallCondition,
    bool? hasAccentWall,
    String? extraNotes,
    Map<String, dynamic>? materialsCalculation,
    double? totalCost,
    bool? complete,
    List<String>? photos,
    List<Map<String, dynamic>>? paintElements,
    Map<String, dynamic>? roomMeasurements,
  }) async {
    try {
      log('[ProjectRepository] Creating project: $projectName');

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        // Campos obrigatórios do projeto
        'project_name': projectName,
        'client_name': clientName,
        'project_type': projectType,
        'contact': contact,

        // Campos obrigatórios do estimate
        'wall_condition': wallCondition ?? 'good',
        'has_accent_wall': hasAccentWall ?? false,
        'total_cost': totalCost ?? 0.0,
        'complete': complete ?? false,

        // Campos opcionais
        if (additionalNotes != null) 'additional_notes': additionalNotes,
        if (extraNotes != null) 'extra_notes': extraNotes,

        // Materials calculation
        if (materialsCalculation != null) ...{
          if (materialsCalculation['gallons_needed'] != null)
            'materials_calculation[gallons_needed]':
                materialsCalculation['gallons_needed'],
          if (materialsCalculation['cans_needed'] != null)
            'materials_calculation[cans_needed]':
                materialsCalculation['cans_needed'],
          if (materialsCalculation['unit'] != null)
            'materials_calculation[unit]':
                materialsCalculation['unit'] ?? 'gallon',
        },
      });

      // Add room measurements (RoomPlan data) separately
      if (roomMeasurements != null) {
        if (roomMeasurements['total_area'] != null) {
          formData.fields.add(
            MapEntry(
              'room_measurements[total_area]',
              roomMeasurements['total_area'].toString(),
            ),
          );
        }

        if (roomMeasurements['rooms'] != null) {
          final rooms = roomMeasurements['rooms'] as List<dynamic>;
          for (int i = 0; i < rooms.length; i++) {
            final room = rooms[i] as Map<String, dynamic>;
            if (room['name'] != null) {
              formData.fields.add(
                MapEntry(
                  'room_measurements[rooms][$i][name]',
                  room['name'].toString(),
                ),
              );
            }
            if (room['floor_area'] != null) {
              formData.fields.add(
                MapEntry(
                  'room_measurements[rooms][$i][floor_area]',
                  room['floor_area'].toString(),
                ),
              );
            }
            if (room['wall_area'] != null) {
              formData.fields.add(
                MapEntry(
                  'room_measurements[rooms][$i][wall_area]',
                  room['wall_area'].toString(),
                ),
              );
            }
          }
        }
      }

      // Add photos if provided
      if (photos != null && photos.isNotEmpty) {
        for (int i = 0; i < photos.length; i++) {
          final photoPath = photos[i];
          final file = File(photoPath);
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'photos[]',
                await MultipartFile.fromFile(
                  photoPath,
                  filename: 'photo_$i.jpg',
                ),
              ),
            );
          }
        }
      } else {
        // Placeholder photos are required by the API (minimum 3)
        // In a real scenario, photos would be provided from the camera
        log(
          '[ProjectRepository] Warning: No photos provided, API requires minimum 3 photos',
        );
      }

      // Add paint elements if provided
      if (paintElements != null && paintElements.isNotEmpty) {
        for (int i = 0; i < paintElements.length; i++) {
          final element = paintElements[i];
          if (element['type'] != null) {
            formData.fields.add(
              MapEntry('paint_elements[$i][type]', element['type']),
            );
          }
          if (element['description'] != null) {
            formData.fields.add(
              MapEntry(
                'paint_elements[$i][description]',
                element['description'],
              ),
            );
          }
          if (element['area'] != null) {
            formData.fields.add(
              MapEntry('paint_elements[$i][area]', element['area'].toString()),
            );
          }
        }
      }

      final response = await _httpService.post(
        '$_baseUrl/estimates',
        data: formData,
      );

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final project = _mapEstimateToProject(data);
          log(
            '[ProjectRepository] Successfully created project: ${project.projectName}',
          );
          return Result.ok(project);
        } else {
          log('[ProjectRepository] Invalid response format');
          return Result.error(Exception('Invalid response format'));
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error creating project';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'creating project');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error creating project: $e'));
    }
  }

  @override
  Future<Result<ProjectModel>> updateProject({
    required String id,
    String? projectName,
    String? clientName,
    String? projectType,
    String? contact,
    String? additionalNotes,
    String? wallCondition,
    bool? hasAccentWall,
    String? extraNotes,
    Map<String, dynamic>? materialsCalculation,
    double? totalCost,
    bool? complete,
    List<String>? photos,
    List<Map<String, dynamic>>? paintElements,
    Map<String, dynamic>? roomMeasurements,
  }) async {
    try {
      log('[ProjectRepository] Updating project with ID: $id');

      final updateData = <String, dynamic>{};

      if (projectName != null) updateData['project_name'] = projectName;
      if (clientName != null) updateData['client_name'] = clientName;
      if (projectType != null) updateData['project_type'] = projectType;
      if (contact != null) updateData['contact'] = contact;
      if (additionalNotes != null) {
        updateData['additional_notes'] = additionalNotes;
      }
      if (wallCondition != null) updateData['wall_condition'] = wallCondition;
      if (hasAccentWall != null) updateData['has_accent_wall'] = hasAccentWall;
      if (extraNotes != null) updateData['extra_notes'] = extraNotes;
      if (totalCost != null) updateData['total_cost'] = totalCost;
      if (complete != null) updateData['complete'] = complete;

      if (materialsCalculation != null) {
        updateData['materials_calculation'] = materialsCalculation;
      }

      if (roomMeasurements != null) {
        updateData['room_measurements'] = roomMeasurements;
      }

      final response = await _httpService.put(
        '$_baseUrl/estimates/$id',
        data: updateData,
      );

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final project = _mapEstimateToProject(data);
          log(
            '[ProjectRepository] Successfully updated project: ${project.projectName}',
          );
          return Result.ok(project);
        } else {
          log('[ProjectRepository] Invalid response format');
          return Result.error(Exception('Invalid response format'));
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error updating project';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'updating project');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error updating project: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteProject(String id) async {
    try {
      log('[ProjectRepository] Deleting project with ID: $id');

      final response = await _httpService.delete('$_baseUrl/estimates/$id');

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('[ProjectRepository] Successfully deleted project');
        return Result.ok(true);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error deleting project';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'deleting project');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error deleting project: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDashboardData() async {
    try {
      log('[ProjectRepository] Getting dashboard data...');

      final response = await _httpService.get('$_baseUrl/estimates/dashboard');

      log('[ProjectRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          log('[ProjectRepository] Successfully loaded dashboard data');
          return Result.ok(data);
        } else {
          log('[ProjectRepository] Invalid response format');
          return Result.error(Exception('Invalid response format'));
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error loading dashboard data';
        log('[ProjectRepository] Error: $errorMessage');
        return Result.error(Exception(errorMessage));
      }
    } on DioException catch (e) {
      log('[ProjectRepository] DioException: ${e.message}');
      return _handleDioException(e, 'loading dashboard data');
    } catch (e) {
      log('[ProjectRepository] Exception: $e');
      return Result.error(Exception('Error loading dashboard data: $e'));
    }
  }

  /// Maps an estimate response to a ProjectModel
  ProjectModel _mapEstimateToProject(Map<String, dynamic> json) {
    // Calculate zones count from paint elements or room measurements
    int zonesCount = 0;

    if (json['paint_elements'] != null && json['paint_elements'] is List) {
      zonesCount = (json['paint_elements'] as List).length;
    } else if (json['room_measurements'] != null &&
        json['room_measurements']['rooms'] != null &&
        json['room_measurements']['rooms'] is List) {
      zonesCount = (json['room_measurements']['rooms'] as List).length;
    } else {
      zonesCount = 1; // Default to at least 1 zone
    }

    // Format creation date
    String createdDate = '';
    if (json['created_at'] != null) {
      try {
        final dateTime = DateTime.parse(json['created_at']);
        createdDate =
            '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}';
      } catch (e) {
        createdDate = json['created_at'].toString();
      }
    }

    // Get first photo or use default
    String image = 'assets/images/kitchen.png'; // Default image
    if (json['photos'] != null &&
        json['photos'] is List &&
        (json['photos'] as List).isNotEmpty) {
      image = (json['photos'] as List).first.toString();
    }

    return ProjectModel(
      id: json['id'] ?? 0,
      projectName: json['project_name'] ?? '',
      personName: json['client_name'] ?? '',
      zonesCount: zonesCount,
      createdDate: createdDate,
      image: image,
    );
  }

  /// Handles DioException with proper error messages
  Result<T> _handleDioException<T>(DioException e, String operation) {
    String errorMessage;

    switch (e.response?.statusCode) {
      case 400:
        errorMessage = 'Bad request. Please check your data.';
        break;
      case 401:
        errorMessage = 'Authentication required. Please log in again.';
        break;
      case 403:
        errorMessage =
            'Access denied. You do not have permission for this operation.';
        break;
      case 404:
        errorMessage = 'Project not found.';
        break;
      case 422:
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData['errors'] != null) {
          final errors = responseData['errors'];
          if (errors is Map<String, dynamic>) {
            final errorDetails = <String>[];
            for (final entry in errors.entries) {
              errorDetails.add('${entry.key}: ${entry.value}');
            }
            errorMessage = 'Validation error: ${errorDetails.join(', ')}';
          } else {
            errorMessage = 'Validation error: $errors';
          }
        } else {
          errorMessage = 'Validation error: Invalid request format';
        }
        break;
      case 500:
        errorMessage = 'Server error: Please try again later';
        break;
      case 503:
        errorMessage = 'Service unavailable: Please try again later';
        break;
      default:
        // Handle network errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage =
              'Connection timeout: Please check your internet connection';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage =
              'Connection error: Please check your internet connection';
        } else {
          errorMessage = 'Error $operation: ${e.message}';
        }
    }

    return Result.error(Exception(errorMessage));
  }
}
