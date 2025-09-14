import 'dart:io';
import 'package:image/image.dart' as img;

import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/zone_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class EstimateUploadUseCase {
  final IEstimateRepository _repository;
  final AppLogger _logger;

  EstimateUploadUseCase(this._repository, this._logger);

  Future<Result<void>> _validate(EstimateModel estimate) async {
    // Validate required fields
    final requiredFieldsResult = _validateRequiredFields(estimate);
    if (requiredFieldsResult is Error) return requiredFieldsResult;

    // Validate zones
    final zonesResult = _validateZones(estimate.zones!);
    if (zonesResult is Error) return zonesResult;

    // Validate photos
    for (final zone in estimate.zones!) {
      for (final data in zone.data) {
        for (final photoPath in data.photoPaths) {
          final photoResult = await _validatePhoto(photoPath);
          if (photoResult is Error) return photoResult;
        }
      }
    }

    return Result.ok(null);
  }

  Result<void> _validateRequiredFields(EstimateModel estimate) {
    if (estimate.contactId?.isEmpty ?? true) {
      return Result.error(
        Exception('Contact ID is required'),
      );
    }
    if (estimate.projectName?.isEmpty ?? true) {
      return Result.error(
        Exception('Project name is required'),
      );
    }
    return Result.ok(null);
  }

  Result<void> _validateZones(List<ZoneModel> zones) {
    if (zones.isEmpty) {
      return Result.error(
        Exception('At least one zone is required'),
      );
    }

    for (var i = 0; i < zones.length; i++) {
      final zone = zones[i];

      if (zone.data.isEmpty) {
        return Result.error(
          Exception('Zone data is required'),
        );
      }

      if (i == 0) {
        final validZoneTypes = ['interior', 'exterior', 'both'];
        if (!validZoneTypes.contains(zone.zoneType.toLowerCase())) {
          return Result.error(
            Exception('Invalid zone type'),
          );
        }
      }

      for (final data in zone.data) {
        if (data.photoPaths.isEmpty) {
          return Result.error(
            Exception('Each zone must have at least one photo'),
          );
        }
      }
    }

    return Result.ok(null);
  }

  Future<Result<void>> _validatePhoto(String photoPath) async {
    try {
      // Validate file extension
      final extensionResult = _validateFileExtension(photoPath);
      if (extensionResult is Error) return extensionResult;

      // Validate file existence and size
      final fileResult = await _validateFileProperties(photoPath);
      if (fileResult is Error) return fileResult;

      // Validate image dimensions (skip for HEIC/HEIF)
      final isHeicFormat =
          photoPath.toLowerCase().endsWith('.heic') ||
          photoPath.toLowerCase().endsWith('.heif');

      if (!isHeicFormat) {
        final dimensionsResult = await _validateImageDimensions(photoPath);
        if (dimensionsResult is Error) return dimensionsResult;
      }

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error validating photo: $e', e);
      return Result.error(
        Exception('Error validating photo'),
      );
    }
  }

  Result<void> _validateFileExtension(String photoPath) {
    final lower = photoPath.toLowerCase();
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.heic',
      '.heif',
    ];
    final isValid = allowedExtensions.any(
      (ext) => lower.endsWith(ext),
    );

    if (!isValid) {
      _logger.error('Invalid photo type: $photoPath', photoPath);
      return Result.error(
        Exception('Invalid photo type'),
      );
    }

    return Result.ok(null);
  }

  Future<Result<void>> _validateFileProperties(String photoPath) async {
    final file = File(photoPath);

    if (!await file.exists()) {
      return Result.error(
        Exception('Photo file does not exist'),
      );
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    final fileSize = await file.length();

    if (fileSize > maxSize) {
      return Result.error(
        Exception('Photo file too large'),
      );
    }

    return Result.ok(null);
  }

  Future<Result<void>> _validateImageDimensions(String photoPath) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.error(
          Exception('Invalid image file'),
        );
      }

      const minWidth = 800, minHeight = 600;
      const maxWidth = 4096, maxHeight = 4096;

      if (image.width < minWidth || image.height < minHeight) {
        return Result.error(
          Exception('Photo dimensions too small'),
        );
      }

      if (image.width > maxWidth || image.height > maxHeight) {
        return Result.error(
          Exception('Photo dimensions too large'),
        );
      }

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error validating image dimensions: $e', e);
      return Result.error(
        Exception('Error validating image dimensions'),
      );
    }
  }

  Future<Result<EstimateModel>> upload(EstimateModel estimate) async {
    _logger.info('[EstimateUploadUseCase] Starting validation');

    final validation = await _validate(estimate);
    if (validation is Error) {
      _logger.warning(
        '[EstimateUploadUseCase] Validation failed: ${validation.asError.error}',
      );
      return Result.error(validation.asError.error);
    }

    _logger.info('[EstimateUploadUseCase] Sending multipart');
    try {
      final result = await _repository.createEstimateMultipart(estimate);

      return result.when(
        ok: (model) {
          _logger.info(
            '[EstimateUploadUseCase] Upload success. Estimate id: ${model.id}',
          );
          return Result.ok(model);
        },
        error: (err) {
          _logger.error('[EstimateUploadUseCase] Upload error: $err', err);
          return Result.error(err);
        },
      );
    } catch (e, st) {
      _logger.error('[EstimateUploadUseCase] Unexpected error: $e', e, st);
      return Result.error(
        Exception('Unexpected error'),
      );
    }
  }
}
