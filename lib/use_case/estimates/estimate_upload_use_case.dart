import 'dart:io';
import 'package:image/image.dart' as img;

import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class EstimateUploadUseCase {
  final IEstimateRepository _repository;
  final AppLogger _logger;

  EstimateUploadUseCase(this._repository, this._logger);

  Future<Result<void>> _validate(EstimateModel estimate) async {
    // contact_id and project_name are required
    if ((estimate.contactId == null) || estimate.contactId!.isEmpty) {
      return Result.error(
        Exception('contact_id is required'),
      );
    }
    if ((estimate.projectName == null) || estimate.projectName!.isEmpty) {
      return Result.error(
        Exception('project_name is required'),
      );
    }

    // Must have at least one zone with data and at least one photo
    if (estimate.zones == null || estimate.zones!.isEmpty) {
      return Result.error(
        Exception('At least one zone is required'),
      );
    }

    for (var i = 0; i < estimate.zones!.length; i++) {
      final zone = estimate.zones![i];
      if (zone.data.isEmpty) {
        return Result.error(
          Exception('Zone data is required'),
        );
      }

      // Validate zone_type only for first zone
      if (i == 0) {
        final validZoneTypes = ['interior', 'exterior', 'both'];
        if (!validZoneTypes.contains(zone.zoneType.toLowerCase())) {
          return Result.error(
            Exception(
              'Invalid zone_type. Must be: interior, exterior, or both',
            ),
          );
        }
      }
      for (final d in zone.data) {
        if (d.photoPaths.isEmpty) {
          return Result.error(
            Exception('Each zone must have at least one photo'),
          );
        }
        // Complete photo validation
        for (final path in d.photoPaths) {
          final validation = await _validatePhoto(path);
          final validationError = validation.when(
            ok: (_) => null,
            error: (e) => e,
          );
          if (validationError != null) {
            return Result.error(validationError);
          }
        }
      }
    }

    return Result.ok(null);
  }

  Future<Result<void>> _validatePhoto(String photoPath) async {
    try {
      // Check file extension
      final lower = photoPath.toLowerCase();
      final allowed =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp') ||
          lower.endsWith('.heic') ||
          lower.endsWith('.heif');
      if (!allowed) {
        return Result.error(
          Exception(
            'Invalid photo type. Allowed: jpg, jpeg, png, webp, heic, heif',
          ),
        );
      }

      // Check file exists
      final file = File(photoPath);
      if (!await file.exists()) {
        return Result.error(
          Exception('Photo file does not exist: $photoPath'),
        );
      }

      // Check file size (max 5MB)
      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxSize) {
        return Result.error(
          Exception('Photo file too large. Maximum size: 5MB'),
        );
      }

      // Check image dimensions (skip for HEIC/HEIF as they're not supported by image package)
      final isHeicFormat = lower.endsWith('.heic') || lower.endsWith('.heif');

      if (!isHeicFormat) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) {
          return Result.error(
            Exception('Invalid image file: $photoPath'),
          );
        }

        const minWidth = 800;
        const minHeight = 600;
        const maxWidth = 4096;
        const maxHeight = 4096;

        if (image.width < minWidth || image.height < minHeight) {
          return Result.error(
            Exception(
              'Photo dimensions too small. Minimum: ${minWidth}x${minHeight}px',
            ),
          );
        }

        if (image.width > maxWidth || image.height > maxHeight) {
          return Result.error(
            Exception(
              'Photo dimensions too large. Maximum: ${maxWidth}x${maxHeight}px',
            ),
          );
        }
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Error validating photo: $e'),
      );
    }
  }

  Future<Result<EstimateModel>> upload(EstimateModel estimate) async {
    _logger.info('[EstimateUploadUseCase] Starting validation');
    final validation = await _validate(estimate);
    final validationFailure = validation.when(
      ok: (_) => null,
      error: (e) => e,
    );

    if (validationFailure != null) {
      _logger.warning(
        '[EstimateUploadUseCase] Validation failed: ${validationFailure.toString()}',
      );
      return Result.error(validationFailure);
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
          _logger.error('[EstimateUploadUseCase] Upload error', err);
          return Result.error(err);
        },
      );
    } catch (e, st) {
      _logger.error(
        '[EstimateUploadUseCase] Unexpected error',
        e as dynamic,
        st,
      );
      return Result.error(
        Exception('Unexpected error: $e'),
      );
    }
  }
}
