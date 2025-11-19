import 'dart:io';

import '../../domain/repository/quote_repository.dart';
import '../../model/quotes_data/quote_list_response.dart';
import '../../model/quotes_data/quote_model.dart';
import '../../model/quotes_data/quote_response.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class QuoteUploadUseCase {
  final IQuoteRepository _quoteRepository;
  final AppLogger _logger;

  QuoteUploadUseCase(this._quoteRepository, this._logger);

  // Helper methods for common operations
  Future<Result<T>> _handleRepositoryCall<T>(
    Future<Result<T>> Function() repositoryCall,
    String operation,
  ) async {
    try {
      final result = await repositoryCall();

      result.when(
        ok: (data) {},
        error: (error) {
          _logger.error('$operation failed: $error', error);
        },
      );

      return result;
    } catch (e) {
      _logger.error('Unexpected error in $operation: $e', e);
      return Result.error(
        Exception('Failed to $operation'),
      );
    }
  }

  /// Upload a quote PDF file for material extraction
  Future<Result<QuoteResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) async {
    return _handleRepositoryCall(
      () => _quoteRepository.uploadQuote(quoteFile, filename: filename),
      'quote upload',
    );
  }

  /// Get list of uploaded quotes with pagination and filters
  Future<Result<QuoteListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) async {
    return _handleRepositoryCall(
      () => _quoteRepository.getQuotes(
        status: status,
        limit: limit,
        page: page,
      ),
      'get quotes',
    );
  }

  /// Check the processing status of a specific quote upload
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId) async {
    return _handleRepositoryCall(
      () => _quoteRepository.getQuoteStatus(quoteId),
      'get quote status',
    );
  }

  /// Update display name of an uploaded quote
  Future<Result<QuoteModel>> updateQuote(
    int quoteId,
    String displayName,
  ) async {
    return _handleRepositoryCall(
      () => _quoteRepository.updateQuote(quoteId, displayName),
      'update quote',
    );
  }

  /// Delete an uploaded quote and all extracted materials
  Future<Result<bool>> deleteQuote(int quoteId) async {
    return _handleRepositoryCall(
      () => _quoteRepository.deleteQuote(quoteId),
      'delete quote',
    );
  }

  /// Poll quote upload status until processing is complete
  Future<Result<QuoteModel>> pollQuoteStatus(
    int quoteId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    return _handleRepositoryCall(
      () => _quoteRepository.pollQuoteStatus(
        quoteId,
        interval: interval,
        timeout: timeout,
      ),
      'poll quote status',
    );
  }
}
