import 'dart:io';

import '../../domain/repository/quote_repository.dart';
import '../../model/models.dart';
import '../../model/pdf_upload/extracted_material_model.dart';
import '../../service/pdf_upload_service.dart';
import '../../utils/result/result.dart';

class QuoteRepository implements IQuoteRepository {
  final QuoteUploadService _quoteUploadService;

  QuoteRepository({
    required QuoteUploadService quoteUploadService,
  }) : _quoteUploadService = quoteUploadService;

  @override
  Future<Result<PdfUploadResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) {
    return _quoteUploadService.uploadQuote(
      quoteFile,
      filename: filename,
    );
  }

  @override
  Future<Result<PdfUploadListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) {
    return _quoteUploadService.getQuotes(
      status: status,
      limit: limit,
      page: page,
    );
  }

  @override
  Future<Result<PdfUploadModel>> getQuoteStatus(int uploadId) {
    return _quoteUploadService.getUploadStatus(uploadId);
  }

  @override
  Future<Result<PdfUploadModel>> updateQuote(
    int uploadId,
    String displayName,
  ) {
    return _quoteUploadService.updateUpload(
      uploadId,
      displayName,
    );
  }

  @override
  Future<Result<bool>> deleteQuote(int uploadId) {
    return _quoteUploadService.deleteUpload(uploadId);
  }

  @override
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  }) {
    return _quoteUploadService.getExtractedMaterials(
      filters: filters,
    );
  }

  @override
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(int materialId) {
    return _quoteUploadService.getExtractedMaterial(materialId);
  }

  @override
  Future<Result<MaterialFiltersOptions>> getFilterOptions() {
    return _quoteUploadService.getFilterOptions();
  }

  @override
  Future<Result<PdfUploadModel>> pollQuoteStatus(
    int uploadId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) {
    return _quoteUploadService.pollQuoteStatus(
      uploadId,
      interval: interval,
      timeout: timeout,
    );
  }
}
