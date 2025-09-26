import 'dart:io';

import '../../domain/repository/quote_repository.dart';
import '../../model/quotes_data/extracted_material_list_response_model.dart';
import '../../model/quotes_data/extracted_material_model.dart';
import '../../model/quotes_data/material_filters_model.dart';
import '../../model/quotes_data/material_filters_options_model.dart';
import '../../model/quotes_data/pagination_info.dart';
import '../../model/quotes_data/quote_list_response.dart';
import '../../model/quotes_data/quote_model.dart';
import '../../model/quotes_data/quote_response.dart';
import '../../service/local/quotes_local_service.dart';
import '../../service/quote_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class QuoteRepository implements IQuoteRepository {
  final QuoteService _quoteService;
  final QuotesLocalService _quotesLocalService;
  final AppLogger _logger;

  QuoteRepository({
    required QuoteService quoteService,
    required QuotesLocalService localStorageService,
    required AppLogger logger,
  }) : _quoteService = quoteService,
       _quotesLocalService = localStorageService,
       _logger = logger;

  @override
  Future<Result<QuoteResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) async {
    try {
      // Try to upload quote via API first
      final apiResult = await _quoteService.uploadQuote(
        quoteFile,
        filename: filename,
      );

      if (apiResult is Ok<QuoteResponse>) {
        final response = apiResult.asOk.value;

        // Cache the newly uploaded quote for offline access
        await _quotesLocalService.saveQuote(response.quote);
        _logger.info(
          'QuoteRepository: Cached newly uploaded quote ${response.quote.id}',
        );

        return Result.ok(response);
      }

      return apiResult;
    } catch (e) {
      _logger.error('QuoteRepository: Error in uploadQuote: $e', e);
      return Result.error(
        Exception('Failed to upload quote'),
      );
    }
  }

  @override
  Future<Result<QuoteListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      // Offline-first strategy: Try to get quotes from local storage first
      _logger.info(
        'QuoteRepository: Attempting to load quotes from offline storage',
      );

      final offlineQuotes = await _quotesLocalService.getAllQuotes();

      if (offlineQuotes.isNotEmpty) {
        _logger.info(
          'QuoteRepository: Found ${offlineQuotes.length} quotes in offline storage',
        );

        // Apply filters to offline data
        List<QuoteModel> filteredQuotes = offlineQuotes;

        // Filter by status if provided
        if (status != null) {
          filteredQuotes = filteredQuotes
              .where((q) => q.status.name == status)
              .toList();
        }

        // Apply pagination
        final startIndex = (page - 1) * limit;
        final paginatedQuotes = filteredQuotes
            .skip(startIndex)
            .take(limit)
            .toList();

        // Calculate pagination info
        final lastPage = (filteredQuotes.length / limit).ceil();
        final from = startIndex + 1;
        final to = (startIndex + paginatedQuotes.length).clamp(
          0,
          filteredQuotes.length,
        );

        // Create response
        final response = QuoteListResponse(
          success: true,
          quotes: paginatedQuotes,
          pagination: PaginationInfo(
            total: filteredQuotes.length,
            perPage: limit,
            currentPage: page,
            lastPage: lastPage,
            from: from,
            to: to,
          ),
        );

        // Try to sync in background (don't wait for it)
        _syncQuotesInBackground();

        return Result.ok(response);
      } else {
        _logger.info(
          'QuoteRepository: No offline quotes found, fetching from API',
        );
      }

      // If no offline data, fetch from API and cache the results
      final apiResult = await _quoteService.getQuotes(
        status: status,
        limit: limit,
        page: page,
      );

      if (apiResult is Ok<QuoteListResponse>) {
        final response = apiResult.asOk.value;

        // Cache all quotes for future offline access
        for (final quote in response.quotes) {
          try {
            await _quotesLocalService.saveQuote(quote);
          } catch (e) {
            _logger.warning(
              'QuoteRepository: Failed to cache quote ${quote.id}: $e',
            );
          }
        }

        _logger.info(
          'QuoteRepository: Cached ${response.quotes.length} quotes from API',
        );
        return Result.ok(response);
      }

      return apiResult;
    } catch (e) {
      _logger.error('QuoteRepository: Error in getQuotes: $e', e);
      return Result.error(
        Exception('Failed to get quotes'),
      );
    }
  }

  /// Sync quotes in background without blocking the UI
  Future<void> _syncQuotesInBackground() async {
    try {
      final apiResult = await _quoteService.getQuotes(limit: 100, page: 1);

      if (apiResult is Ok<QuoteListResponse>) {
        final response = apiResult.asOk.value;

        // Update cached quotes
        for (final quote in response.quotes) {
          try {
            await _quotesLocalService.saveQuote(quote);
          } catch (e) {
            _logger.warning(
              'QuoteRepository: Failed to update cached quote ${quote.id}: $e',
            );
          }
        }

        _logger.info(
          'QuoteRepository: Background sync completed - updated ${response.quotes.length} quotes',
        );
      }
    } catch (e) {
      _logger.warning('QuoteRepository: Background sync failed');
    }
  }

  @override
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId) async {
    try {
      // Offline-first strategy: Try to get quote status from local storage first
      _logger.info(
        'QuoteRepository: Attempting to load quote status $quoteId from offline storage',
      );

      final offlineQuote = await _quotesLocalService.getQuote(quoteId);

      if (offlineQuote != null) {
        _logger.info(
          'QuoteRepository: Found quote $quoteId in offline storage',
        );

        // Try to get latest status from API in background
        _updateQuoteStatusInBackground(quoteId);

        return Result.ok(offlineQuote);
      } else {
        _logger.info(
          'QuoteRepository: Quote $quoteId not found in offline storage, fetching from API',
        );
      }

      // If not found offline, try API and cache the result
      final apiResult = await _quoteService.getQuoteStatus(quoteId);

      if (apiResult is Ok<QuoteModel>) {
        final quote = apiResult.asOk.value;

        // Cache the quote for future offline access
        await _quotesLocalService.saveQuote(quote);
        _logger.info('QuoteRepository: Cached quote $quoteId from API');

        return Result.ok(quote);
      }

      return apiResult;
    } catch (e) {
      _logger.error('QuoteRepository: Error in getQuoteStatus: $e', e);
      return Result.error(
        Exception('Failed to get quote status'),
      );
    }
  }

  /// Update quote status in background without blocking the UI
  Future<void> _updateQuoteStatusInBackground(int quoteId) async {
    try {
      final apiResult = await _quoteService.getQuoteStatus(quoteId);

      if (apiResult is Ok<QuoteModel>) {
        final updatedQuote = apiResult.asOk.value;
        await _quotesLocalService.saveQuote(updatedQuote);
        _logger.info(
          'QuoteRepository: Updated quote $quoteId status in background',
        );
      }
    } catch (e) {
      _logger.warning(
        'QuoteRepository: Failed to update quote $quoteId status in background: $e',
      );
    }
  }

  @override
  Future<Result<QuoteModel>> updateQuote(
    int quoteId,
    String displayName,
  ) {
    return _quoteService.updateQuote(
      quoteId,
      displayName,
    );
  }

  @override
  Future<Result<bool>> deleteQuote(int quoteId) async {
    try {
      // Try to delete quote via API first
      final apiResult = await _quoteService.deleteQuote(quoteId);

      if (apiResult is Ok<bool> && apiResult.asOk.value) {
        // Remove from offline cache
        await _quotesLocalService.deleteQuote(quoteId);
        _logger.info(
          'QuoteRepository: Removed deleted quote $quoteId from cache',
        );

        return Result.ok(true);
      }

      return apiResult;
    } catch (e) {
      _logger.error('QuoteRepository: Error in deleteQuote: $e', e);
      return Result.error(
        Exception('Failed to delete quote'),
      );
    }
  }

  @override
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  }) {
    return _quoteService.getExtractedMaterials(
      filters: filters,
    );
  }

  @override
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(int materialId) {
    return _quoteService.getExtractedMaterial(materialId);
  }

  @override
  Future<Result<MaterialFiltersOptions>> getFilterOptions() {
    return _quoteService.getFilterOptions();
  }

  @override
  Future<Result<QuoteModel>> pollQuoteStatus(
    int quoteId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) {
    return _quoteService.pollQuoteStatus(
      quoteId,
      interval: interval,
      timeout: timeout,
    );
  }
}
