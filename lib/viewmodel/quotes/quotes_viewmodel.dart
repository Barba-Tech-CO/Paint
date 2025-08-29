import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../model/quotes/quotes_model.dart';
import '../../use_case/quotes/quote_upload_use_case.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

enum QuotesState { loading, empty, loaded, error }

class QuotesViewModel extends ChangeNotifier {
  final QuoteUploadUseCase _quoteUploadUseCase;
  final AppLogger _logger;

  QuotesState _currentState = QuotesState.empty;
  bool _isUploading = false;
  String? _errorMessage;

  // Lista de quotes
  final List<QuotesModel> _quotes = [];
  final List<QuotesModel> _filteredQuotes = [];
  String _searchQuery = '';

  // Construtor
  QuotesViewModel(this._quoteUploadUseCase, this._logger) {
    _loadQuotes();
  }

  // Getters
  QuotesState get currentState => _currentState;
  List<QuotesModel> get quotes => _searchQuery.isEmpty
      ? List.unmodifiable(_quotes)
      : List.unmodifiable(_filteredQuotes);
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasQuotes => _quotes.isNotEmpty;

  /// Carrega quotes existentes
  Future<Result<void>> _loadQuotes() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _quoteUploadUseCase.getQuotes();

      return result.when(
        ok: (response) {
          _quotes.clear();
          if (response.uploads.isNotEmpty) {
            _quotes.addAll(
              response.uploads.map(
                (upload) => QuotesModel.fromPdfUpload(upload),
              ),
            );
          }
          _updateState();
          return Result.ok(null);
        },
        error: (error) {
          _setError('Failed to load quotes: ${error.toString()}');
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error loading quotes: $e');
      return Result.error(Exception(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona e faz upload de um arquivo PDF
  Future<Result<void>> pickFile() async {
    try {
      _setLoading(true);
      _clearError();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Log file information for debugging
        _logger.info('Selected file: $fileName');
        _logger.info('File path: ${file.path}');
        _logger.info('File size: ${await file.length()} bytes');

        // Validações básicas
        final validationResult = await _validateFile(file);
        if (!validationResult) {
          return Result.error(Exception('File validation failed'));
        }

        // Faz upload do arquivo
        return await _uploadPdfFile(file, fileName);
      } else {
        // Usuário cancelou
        _updateState();
        _logger.info('File selection cancelled');
        return Result.ok(null);
      }
    } catch (e) {
      _setError('Error selecting file: $e');
      _logger.error('Error in pickFile: $e', e);
      return Result.error(Exception(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  /// Valida o arquivo antes do upload
  Future<bool> _validateFile(File file) async {
    try {
      // Verifica se o arquivo existe
      if (!await file.exists()) {
        _setError('Selected file does not exist');
        return false;
      }

      // Verifica o tamanho do arquivo (25MB máximo)
      final fileSize = await file.length();
      const maxSize = 25 * 1024 * 1024; // 25MB em bytes

      if (fileSize > maxSize) {
        _setError('File size exceeds 25MB limit');
        return false;
      }

      // Verifica a extensão
      final extension = file.path.split('.').last.toLowerCase();
      if (extension != 'pdf') {
        _setError('Only PDF files are allowed');
        return false;
      }

      // Verifica se o arquivo não está vazio
      if (fileSize == 0) {
        _setError('Selected file is empty');
        return false;
      }

      // Verifica se o nome do arquivo é válido
      final fileName = file.path.split('/').last;
      if (fileName.isEmpty || fileName.length > 255) {
        _setError('Invalid file name');
        return false;
      }

      // Verifica se o arquivo pode ser lido
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          _setError('Cannot read file content');
          return false;
        }

        // Basic PDF header validation (PDF files start with %PDF)
        if (bytes.length >= 4) {
          final header = String.fromCharCodes(bytes.take(4));
          if (header != '%PDF') {
            _setError('File does not appear to be a valid PDF');
            return false;
          }
        }

        // Note: Backend validation will check for USD currency requirement
        // Documents with other currencies (R$, €, £, etc.) will be rejected
        _logger.info(
          'File validation passed. Note: Backend requires USD currency in PDF content.',
        );
      } catch (e) {
        _setError('Cannot read file: $e');
        return false;
      }

      return true;
    } catch (e) {
      _setError('Error validating file: $e');
      return false;
    }
  }

  /// Faz upload do arquivo PDF
  Future<Result<void>> _uploadPdfFile(File file, String fileName) async {
    try {
      _setUploading(true);
      _clearError();

      final result = await _quoteUploadUseCase.uploadQuote(
        file,
        filename: fileName,
      );

      return result.when(
        ok: (response) {
          // Cria um novo quote com os dados da resposta
          final newQuote = QuotesModel.fromPdfUpload(response.upload);

          // Adiciona à lista
          _quotes.add(newQuote);
          _updateState();

          _logger.info('Quote uploaded successfully: ${newQuote.titulo}');
          _logger.info('Status: ${newQuote.statusDisplay}');

          // Se o status for pending ou processing, inicia polling para acompanhar o progresso
          if (newQuote.isPending || newQuote.isProcessing) {
            _startStatusPolling(newQuote.id);
          }

          return Result.ok(null);
        },
        error: (error) {
          // Provide more specific error messages based on error type
          String errorMessage;
          if (error.toString().contains('Validation error:')) {
            errorMessage = error.toString().replaceFirst(
              'Exception: Validation error: ',
              '',
            );
          } else if (error.toString().contains('422')) {
            // Check if it's an infrastructure error (like Cloudflare R2 connection issues)
            if (error.toString().contains('Cloudflare') ||
                error.toString().contains('TLS') ||
                error.toString().contains('PutObject') ||
                error.toString().contains('cURL error')) {
              errorMessage =
                  'Server infrastructure error. This is a temporary issue.\n\n'
                  'Please try again in a few minutes. If the problem persists, '
                  'contact support.';
            } else {
              errorMessage =
                  'The PDF file could not be processed. This may be due to:\n'
                  '• Non-USD currency in the document (only \$ accepted)\n'
                  '• Invalid PDF format\n'
                  '• File content validation failed\n\n'
                  'Please check your PDF and try again.';
            }
          } else if (error.toString().contains('401') ||
              error.toString().contains('403')) {
            errorMessage = 'Authentication failed. Please log in again.';
          } else if (error.toString().contains('413') ||
              error.toString().contains('25MB')) {
            errorMessage =
                'File size exceeds the 25MB limit. Please choose a smaller file.';
          } else {
            errorMessage = 'Upload failed: ${error.toString()}';
          }

          _setError(errorMessage);
          _logger.error('Upload error: $error', error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error during upload: $e');
      _logger.error('Unexpected upload error: $e', e);
      return Result.error(Exception(e.toString()));
    } finally {
      _setUploading(false);
    }
  }

  /// Inicia polling do status do upload
  Future<Result<void>> _startStatusPolling(String quoteId) async {
    try {
      final uploadId = int.tryParse(quoteId);
      if (uploadId == null) {
        return Result.error(Exception('Invalid quote ID for polling'));
      }

      final result = await _quoteUploadUseCase.pollQuoteStatus(uploadId);

      return result.when(
        ok: (upload) {
          // Atualiza o quote na lista com o novo status
          final index = _quotes.indexWhere((q) => q.id == quoteId);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromPdfUpload(upload);
            _updateState();
            notifyListeners();

            _logger.info('Quote status updated: ${upload.status.value}');

            // Se o status for final, para o polling
            if (upload.isCompleted || upload.isFailed || upload.isError) {
              _logger.info('Quote processing completed, stopping polling');
            }
          }

          return Result.ok(null);
        },
        error: (error) {
          _logger.error('Status polling failed: $error', error);
          // Não mostra erro para o usuário, apenas log
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error('Error in status polling: $e', e);
      return Result.error(Exception(e.toString()));
    }
  }

  /// Remove um quote
  Future<Result<void>> removeQuote(String id) async {
    try {
      final uploadId = int.tryParse(id);
      if (uploadId == null) {
        return Result.error(Exception('Invalid quote ID'));
      }

      final result = await _quoteUploadUseCase.deleteQuote(uploadId);

      return result.when(
        ok: (_) {
          _quotes.removeWhere((quote) => quote.id == id);
          _updateState();
          notifyListeners();
          _logger.info('Quote deleted successfully');
          return Result.ok(null);
        },
        error: (error) {
          _setError('Failed to delete quote: ${error.toString()}');
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error deleting quote: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  /// Renomeia um quote
  Future<Result<void>> renameQuote(String id, String newTitle) async {
    try {
      final uploadId = int.tryParse(id);
      if (uploadId == null) {
        return Result.error(Exception('Invalid quote ID'));
      }

      final result = await _quoteUploadUseCase.updateQuote(uploadId, newTitle);

      return result.when(
        ok: (upload) {
          final index = _quotes.indexWhere((quote) => quote.id == id);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromPdfUpload(upload);
            _filterQuotes(); // Re-apply filter after rename
            notifyListeners();
            _logger.info('Quote renamed successfully');
          }

          return Result.ok(null);
        },
        error: (error) {
          _setError('Failed to rename quote: ${error.toString()}');
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error renaming quote: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  /// Busca quotes
  void searchQuotes(String query) {
    _searchQuery = query.toLowerCase();
    _filterQuotes();
    notifyListeners();
  }

  /// Filtra quotes baseado na busca
  void _filterQuotes() {
    if (_searchQuery.isEmpty) {
      _filteredQuotes.clear();
    } else {
      _filteredQuotes.clear();
      _filteredQuotes.addAll(
        _quotes.where(
          (quote) =>
              quote.titulo.toLowerCase().contains(_searchQuery) ||
              quote.id.toLowerCase().contains(_searchQuery),
        ),
      );
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    _updateState();
  }

  /// Recarrega quotes
  Future<Result<void>> refresh() async {
    return await _loadQuotes();
  }

  // Métodos privados para gerenciar estado
  void _updateState() {
    if (_quotes.isEmpty) {
      _currentState = QuotesState.empty;
    } else {
      _currentState = QuotesState.loaded;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (loading) {
      _currentState = QuotesState.loading;
    }
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _currentState = QuotesState.error;
    _isUploading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
