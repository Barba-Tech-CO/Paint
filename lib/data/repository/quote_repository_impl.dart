import 'dart:io';

import '../../domain/repository/quote_repository.dart';
import '../../model/models.dart';
import '../../model/quotes_data/extracted_material_model.dart';
import '../../service/quote_service.dart';
import '../../utils/result/result.dart';

class QuoteRepository implements IQuoteRepository {
  final QuoteService _quoteService;

  QuoteRepository({
    required QuoteService quoteService,
  }) : _quoteService = quoteService;

  @override
  Future<Result<QuoteResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) {
    return _quoteService.uploadQuote(
      quoteFile,
      filename: filename,
    );
  }

  @override
  Future<Result<QuoteListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) {
    return _quoteService.getQuotes(
      status: status,
      limit: limit,
      page: page,
    );
  }

  @override
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId) {
    return _quoteService.getQuoteStatus(quoteId);
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
  Future<Result<bool>> deleteQuote(int quoteId) {
    return _quoteService.deleteQuote(quoteId);
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
