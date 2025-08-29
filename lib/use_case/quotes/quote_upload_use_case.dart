import 'dart:io';

import '../../domain/repository/quote_repository.dart';
import '../../model/models.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class QuoteUploadUseCase {
  final IQuoteRepository _quoteRepository;
  final AppLogger _logger;

  QuoteUploadUseCase(this._quoteRepository, this._logger);

  /// Upload a quote PDF file for material extraction
  Future<Result<PdfUploadResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) async {
    try {
      _logger.info('Starting quote upload for file: ${quoteFile.path}');

      final result = await _quoteRepository.uploadQuote(
        quoteFile,
        filename: filename,
      );

      result.when(
        ok: (response) {
          _logger.info(
            'Quote upload successful: ${response.upload.originalName}',
          );
        },
        error: (error) {
          _logger.error('Quote upload failed: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error in quote upload: $e', e);
      return Result.error(Exception('Failed to upload quote: $e'));
    }
  }

  /// Get list of uploaded quotes with pagination and filters
  Future<Result<PdfUploadListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      _logger.info('Fetching quotes with status: $status, page: $page');

      final result = await _quoteRepository.getQuotes(
        status: status,
        limit: limit,
        page: page,
      );

      result.when(
        ok: (response) {
          _logger.info('Retrieved ${response.uploads.length} quotes');
        },
        error: (error) {
          _logger.error('Failed to retrieve quotes: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error getting quotes: $e', e);
      return Result.error(Exception('Failed to get quotes: $e'));
    }
  }

  /// Check the processing status of a specific quote upload
  Future<Result<PdfUploadModel>> getQuoteStatus(int uploadId) async {
    try {
      _logger.info('Checking status for quote upload: $uploadId');

      final result = await _quoteRepository.getQuoteStatus(uploadId);

      result.when(
        ok: (upload) {
          _logger.info('Quote status: ${upload.status.value}');
        },
        error: (error) {
          _logger.error('Failed to get quote status: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error getting quote status: $e', e);
      return Result.error(Exception('Failed to get quote status: $e'));
    }
  }

  /// Update display name of an uploaded quote
  Future<Result<PdfUploadModel>> updateQuote(
    int uploadId,
    String displayName,
  ) async {
    try {
      _logger.info('Updating quote display name: $uploadId -> $displayName');

      final result = await _quoteRepository.updateQuote(uploadId, displayName);

      result.when(
        ok: (upload) {
          _logger.info('Quote updated successfully');
        },
        error: (error) {
          _logger.error('Failed to update quote: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error updating quote: $e', e);
      return Result.error(Exception('Failed to update quote: $e'));
    }
  }

  /// Delete an uploaded quote and all extracted materials
  Future<Result<bool>> deleteQuote(int uploadId) async {
    try {
      _logger.info('Deleting quote upload: $uploadId');

      final result = await _quoteRepository.deleteQuote(uploadId);

      result.when(
        ok: (_) {
          _logger.info('Quote deleted successfully');
        },
        error: (error) {
          _logger.error('Failed to delete quote: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error deleting quote: $e', e);
      return Result.error(Exception('Failed to delete quote: $e'));
    }
  }

  /// Poll quote upload status until processing is complete
  Future<Result<PdfUploadModel>> pollQuoteStatus(
    int uploadId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    try {
      _logger.info('Starting status polling for quote: $uploadId');

      final result = await _quoteRepository.pollQuoteStatus(
        uploadId,
        interval: interval,
        timeout: timeout,
      );

      result.when(
        ok: (upload) {
          _logger.info(
            'Quote processing completed with status: ${upload.status.value}',
          );
        },
        error: (error) {
          _logger.error('Quote processing failed or timed out: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error polling quote status: $e', e);
      return Result.error(Exception('Failed to poll quote status: $e'));
    }
  }
}
