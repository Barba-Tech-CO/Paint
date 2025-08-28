import 'dart:io';

import '../../model/pdf_upload/pdf_upload_model.dart';
import '../../model/pdf_upload/extracted_material_model.dart';
import '../../utils/result/result.dart';

abstract class IQuoteRepository {
  /// Upload a quote PDF file for material extraction
  Future<Result<PdfUploadResponse>> uploadQuote(File quoteFile);

  /// Get list of uploaded quotes with pagination and filters
  Future<Result<PdfUploadListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  });

  /// Check the processing status of a specific quote upload
  Future<Result<PdfUploadModel>> getQuoteStatus(int uploadId);

  /// Update display name of an uploaded quote
  Future<Result<PdfUploadModel>> updateQuote(int uploadId, String displayName);

  /// Delete an uploaded quote and all extracted materials
  Future<Result<bool>> deleteQuote(int uploadId);

  /// Get extracted materials from quotes with filtering and pagination
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  });

  /// Get a specific extracted material by ID
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(int materialId);

  /// Get available filter options for extracted materials
  Future<Result<MaterialFiltersOptions>> getFilterOptions();

  /// Poll quote upload status until processing is complete
  Future<Result<PdfUploadModel>> pollQuoteStatus(
    int uploadId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  });
}