import 'dart:io';

import '../../model/quotes_data/quote_list_response.dart';
import '../../model/quotes_data/quote_model.dart';
import '../../model/quotes_data/quote_response.dart';
import '../../model/quotes_data/extracted_material_model.dart';
import '../../utils/result/result.dart';

abstract class IQuoteRepository {
  /// Upload a quote PDF file for material extraction
  Future<Result<QuoteResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  });

  /// Get list of uploaded quotes with pagination and filters
  Future<Result<QuoteListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  });

  /// Check the processing status of a specific quote upload
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId);

  /// Update display name of an uploaded quote
  Future<Result<QuoteModel>> updateQuote(int quoteId, String displayName);

  /// Delete an uploaded quote and all extracted materials
  Future<Result<bool>> deleteQuote(int quoteId);

  /// Get extracted materials from quotes with filtering and pagination
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  });

  /// Get a specific extracted material by ID
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(int materialId);

  /// Get available filter options for extracted materials
  Future<Result<MaterialFiltersOptions>> getFilterOptions();

  /// Poll quote upload status until processing is complete
  Future<Result<QuoteModel>> pollQuoteStatus(
    int quoteId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  });
}
