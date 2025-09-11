import 'dart:io';

import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_create_request.dart';
import '../../utils/result/result.dart';
import '../../utils/logger/app_logger.dart';

/// Use case for handling estimate creation with validation and business logic
class EstimateCreationUseCase {
  final IEstimateRepository _estimateRepository;
  final AppLogger _logger;

  EstimateCreationUseCase(
    this._estimateRepository,
    this._logger,
  );

  /// Creates a complete estimate with multipart upload
  Future<Result<EstimateModel>> createEstimateMultipart(
    EstimateCreateRequest request,
  ) async {
    try {
      _logger.info('Starting estimate creation with multipart upload');

      // Validate request
      final validationResult = _validateRequest(request);
      if (validationResult is Error) {
        _logger.error(
          'Estimate validation failed: ${(validationResult).error}',
        );
        return Result.error(
          (validationResult).error,
        );
      }

      // Validate photos for each zone
      for (int i = 0; i < request.zones.length; i++) {
        final zone = request.zones[i];
        final photoValidationResult = _validateZonePhotos(zone.photos, i);
        if (photoValidationResult is Error) {
          _logger.error('Zone photo validation failed for ${zone.name}');
          return Result.error(
            (photoValidationResult).error,
          );
        }
      }

      _logger.info('Validation passed, creating estimate via repository');

      // Call repository to create estimate
      final result = await _estimateRepository.createEstimateMultipart(request);

      return result.when(
        ok: (estimate) {
          _logger.info(
            'Estimate created successfully with ID: ${estimate.id}',
          );
          return Result.ok(estimate);
        },
        error: (error) {
          _logger.error('Failed to create estimate: $error');
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error('Unexpected error in createEstimateMultipart: $e');
      return Result.error(
        Exception('Failed to create estimate'),
      );
    }
  }

  /// Validates the estimate creation request
  Result<void> _validateRequest(EstimateCreateRequest request) {
    // Contact ID validation
    if (request.contactId.trim().isEmpty) {
      return Result.error(
        Exception('Please enter the contact ID'),
      );
    }

    // Project name validation
    if (request.projectName.trim().isEmpty) {
      return Result.error(
        Exception('Please enter the project name'),
      );
    }

    if (request.projectName.trim().length < 3) {
      return Result.error(
        Exception('Project name must be at least 3 characters'),
      );
    }

    // Zones validation
    if (request.zones.isEmpty) {
      return Result.error(
        Exception('Add at least one zone to the project'),
      );
    }

    // Zone type validation (only first zone should have zone_type)
    if (request.zones.first.zoneType == null) {
      return Result.error(
        Exception(
          'Please define the first zone type',
        ),
      );
    }

    // Validate each zone
    for (int i = 0; i < request.zones.length; i++) {
      final zone = request.zones[i];
      final zoneValidation = _validateZone(zone, i);
      if (zoneValidation is Error) {
        return zoneValidation;
      }
    }

    // Materials validation
    if (request.materials.isEmpty) {
      return Result.error(
        Exception('Add at least one material to the project'),
      );
    }

    // Validate materials
    for (int i = 0; i < request.materials.length; i++) {
      final material = request.materials[i];
      final materialValidation = _validateMaterial(material, i);
      if (materialValidation is Error) {
        return materialValidation;
      }
    }

    // Totals validation
    final totalsValidation = _validateTotals(request.totals);
    if (totalsValidation is Error) {
      return totalsValidation;
    }

    return Result.ok(null);
  }

  /// Validates individual zone data
  Result<void> _validateZone(dynamic zone, int index) {
    if (zone.id.trim().isEmpty) {
      return Result.error(
        Exception('Please define zone ${index + 1} ID'),
      );
    }

    if (zone.name.trim().isEmpty) {
      return Result.error(
        Exception('Please name zone ${index + 1}'),
      );
    }

    // Validate floor dimensions
    final fd = zone.floorDimensions;
    if (fd.length <= 0 || fd.width <= 0 || fd.height <= 0) {
      return Result.error(
        Exception(
          'Check dimensions for zone ${zone.name}',
        ),
      );
    }

    // Validate surface areas (at least walls should exist)
    if (zone.surfaceAreas.walls.isEmpty) {
      return Result.error(
        Exception('Add at least one wall to zone ${zone.name}'),
      );
    }

    return Result.ok(null);
  }

  /// Validates zone photos
  Result<void> _validateZonePhotos(List<File> photos, int zoneIndex) {
    if (photos.isEmpty) {
      return Result.error(
        Exception('Add at least one photo to zone ${zoneIndex + 1}'),
      );
    }

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final photoValidation = _validatePhoto(photo, zoneIndex, i);
      if (photoValidation is Error) {
        return photoValidation;
      }
    }

    return Result.ok(null);
  }

  /// Validates individual photo file
  Result<void> _validatePhoto(File photo, int zoneIndex, int photoIndex) {
    // Check if file exists
    if (!photo.existsSync()) {
      return Result.error(
        Exception(
          'Zona ${zoneIndex + 1}, Foto ${photoIndex + 1}: Arquivo não encontrado',
        ),
      );
    }

    // Check file size (max 5MB)
    const maxSizeBytes = 5 * 1024 * 1024; // 5MB
    final fileSizeBytes = photo.lengthSync();
    if (fileSizeBytes > maxSizeBytes) {
      return Result.error(
        Exception(
          'Zona ${zoneIndex + 1}, Foto ${photoIndex + 1}: Arquivo muito grande (máx. 5MB)',
        ),
      );
    }

    // Check file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final fileName = photo.path.toLowerCase();
    final hasValidExtension = allowedExtensions.any(
      (ext) => fileName.endsWith(ext),
    );

    if (!hasValidExtension) {
      return Result.error(
        Exception(
          'Zona ${zoneIndex + 1}, Foto ${photoIndex + 1}: Formato não suportado (use JPG, PNG ou WebP)',
        ),
      );
    }

    return Result.ok(null);
  }

  /// Validates material data
  Result<void> _validateMaterial(dynamic material, int index) {
    if (material.id.trim().isEmpty) {
      return Result.error(
        Exception('Please enter material ${index + 1} ID'),
      );
    }

    if (material.unit.trim().isEmpty) {
      return Result.error(
        Exception('Please enter material ${index + 1} unit'),
      );
    }

    if (material.quantity <= 0) {
      return Result.error(
        Exception('Material ${index + 1} quantity must be greater than zero'),
      );
    }

    if (material.unitPrice <= 0) {
      return Result.error(
        Exception(
          'Material ${index + 1} unit price must be greater than zero',
        ),
      );
    }

    return Result.ok(null);
  }

  /// Validates totals data
  Result<void> _validateTotals(dynamic totals) {
    if (totals.materialsCost <= 0) {
      return Result.error(
        Exception('Total materials cost must be greater than zero'),
      );
    }

    if (totals.grandTotal <= 0) {
      return Result.error(
        Exception('Grand total must be greater than zero'),
      );
    }

    // Grand total should be at least the materials cost
    if (totals.grandTotal < totals.materialsCost) {
      return Result.error(
        Exception(
          'Total geral deve ser pelo menos igual ao custo dos materiais',
        ),
      );
    }

    return Result.ok(null);
  }
}
