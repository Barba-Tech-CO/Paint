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

  // State management
  QuotesState _currentState = QuotesState.loading;
  final bool _isLoading = false;
  bool _isUploading = false;
  bool _isDeleting = false; // Add deleting state
  String? _error;

  // Data
  final List<QuotesModel> _quotes = [];
  final List<QuotesModel> _filteredQuotes = [];
  String _searchQuery = '';

  // Polling management - prevent multiple polling instances for the same quote
  final Set<String> _pollingQuotes = <String>{};

  // Delete management - track which quote is being deleted
  final Set<String> _deletingQuotes = <String>{};

  // Debounce mechanism to prevent excessive UI updates
  DateTime? _lastUpdateTime;
  static const Duration _updateDebounceTime = Duration(milliseconds: 500);

  // Getters
  QuotesState get currentState => _currentState;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting; // Add getter for deleting state
  String? get error => _error;
  List<QuotesModel> get quotes => _quotes;
  List<QuotesModel> get filteredQuotes => _filteredQuotes;
  String get searchQuery => _searchQuery;

  /// Check if a specific quote is being deleted
  bool isQuoteBeingDeleted(String quoteId) => _deletingQuotes.contains(quoteId);

  // Construtor
  QuotesViewModel(this._quoteUploadUseCase, this._logger) {
    _loadQuotes();
  }

  @override
  void dispose() {
    _stopAllPolling();
    super.dispose();
  }

  /// Carrega quotes existentes
  Future<Result<void>> _loadQuotes() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _quoteUploadUseCase.getQuotes();

      return result.when(
        ok: (response) {
          _quotes.clear();
          if (response.quotes.isNotEmpty) {
            _quotes.addAll(
              response.quotes.map(
                (upload) => QuotesModel.fromQuote(upload),
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
          final newQuote = QuotesModel.fromQuote(response.quote);

          // Adiciona à lista
          _quotes.add(newQuote);
          _updateState();

          _logger.info('Quote uploaded successfully: ${newQuote.titulo}');
          _logger.info('Status: ${newQuote.statusDisplay}');

          // Se o status for pending ou processing, inicia polling para acompanhar o progresso
          if (newQuote.isPending || newQuote.isProcessing) {
            _logger.info(
              'Starting status polling for new quote: ${newQuote.id} (${newQuote.statusDisplay})',
            );
            _startStatusPolling(newQuote.id);
          } else {
            _logger.info(
              'Quote ${newQuote.id} has final status: ${newQuote.statusDisplay}, no polling needed',
            );
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

  /// Stops polling for a specific quote
  void _stopPolling(String quoteId) {
    if (_pollingQuotes.remove(quoteId)) {
      _logger.info('Stopped polling for quote: $quoteId');
    }
  }

  /// Stops polling for a specific quote (public method)
  void stopPollingForQuote(String quoteId) {
    _stopPolling(quoteId);
  }

  /// Stops all active polling
  void _stopAllPolling() {
    if (_pollingQuotes.isNotEmpty) {
      _logger.info(
        'Stopping all active polling for ${_pollingQuotes.length} quotes',
      );
      _pollingQuotes.clear();
    }
  }

  /// Force stops all polling (public method for emergency situations)
  void forceStopAllPolling() {
    _logger.warning(
      'Force stopping all polling - this may indicate a backend issue',
    );
    _stopAllPolling();
  }

  /// Gets current polling status for debugging
  Set<String> get currentPollingQuotes => Set.from(_pollingQuotes);

  /// Gets detailed polling status for debugging
  Map<String, dynamic> get pollingStatus {
    return {
      'active_polling_count': _pollingQuotes.length,
      'active_polling_quotes': _pollingQuotes.toList(),
      'last_update_time': _lastUpdateTime?.toIso8601String(),
      'current_state': _currentState.toString(),
    };
  }

  /// Shows current polling status in logs for debugging
  void logPollingStatus() {
    _logger.info('Current polling status: $pollingStatus');
  }

  /// Inicia polling do status do upload
  Future<Result<void>> _startStatusPolling(String quoteId) async {
    // Prevent multiple polling instances for the same quote
    if (_pollingQuotes.contains(quoteId)) {
      _logger.info(
        'Quote $quoteId is already being polled, skipping duplicate request',
      );
      return Result.ok(null);
    }

    // Mark this quote as being polled
    _pollingQuotes.add(quoteId);

    try {
      final parsedQuoteId = int.tryParse(quoteId);
      if (parsedQuoteId == null) {
        _pollingQuotes.remove(quoteId); // Clean up
        return Result.error(
          Exception('Invalid quote ID for polling'),
        );
      }

      _logger.info('Starting status polling for quote: $quoteId');

      final result = await _quoteUploadUseCase.pollQuoteStatus(parsedQuoteId);

      return result.when(
        ok: (upload) {
          // Atualiza o quote na lista com o novo status
          final index = _quotes.indexWhere((q) => q.id == quoteId);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromQuote(upload);
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
          // Log the specific error to help debug
          if (error.toString().contains('stuck')) {
            _logger.warning(
              'Quote $quoteId polling stopped due to stuck status - this may indicate a backend issue',
            );
          } else if (error.toString().contains('delayed')) {
            _logger.warning(
              'Quote $quoteId polling stopped due to processing delay - backend may not be processing PDFs',
            );
          }
          // Não mostra erro para o usuário, apenas log
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error('Error in status polling: $e', e);
      return Result.error(Exception(e.toString()));
    } finally {
      // Always clean up the polling set
      _pollingQuotes.remove(quoteId);
    }
  }

  /// Remove um quote
  Future<Result<void>> removeQuote(String id) async {
    try {
      _setDeleting(true);
      _deletingQuotes.add(id); // Track this specific quote
      _clearError();

      final quoteId = int.tryParse(id);
      if (quoteId == null) {
        return Result.error(Exception('Invalid quote ID'));
      }

      _logger.info('Starting delete operation for quote: $id');

      final result = await _quoteUploadUseCase.deleteQuote(quoteId);

      return result.when(
        ok: (_) {
          // Remove the quote from the list
          _quotes.removeWhere((quote) => quote.id == id);

          // Stop polling for this specific quote if it was being polled
          _stopPolling(id);

          _updateState();
          notifyListeners();
          _logger.info('Quote deleted successfully: $id');

          return Result.ok(null);
        },
        error: (error) {
          _setError('Failed to delete quote: ${error.toString()}');
          _logger.error('Delete operation failed for quote $id: $error', error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error deleting quote: $e');
      _logger.error(
        'Unexpected error in delete operation for quote $id: $e',
        e,
      );
      return Result.error(Exception(e.toString()));
    } finally {
      _setDeleting(false); // Reset deleting state
      _deletingQuotes.remove(id); // Remove from deleting set
    }
  }

  /// Renomeia um quote
  Future<Result<void>> renameQuote(String id, String newTitle) async {
    try {
      final quoteId = int.tryParse(id);
      if (quoteId == null) {
        return Result.error(Exception('Invalid quote ID'));
      }

      final result = await _quoteUploadUseCase.updateQuote(quoteId, newTitle);

      return result.when(
        ok: (upload) {
          final index = _quotes.indexWhere((quote) => quote.id == id);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromQuote(upload);
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
    _error = null;
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

    // Use debouncing to prevent excessive UI updates during polling
    final now = DateTime.now();
    if (_lastUpdateTime == null ||
        now.difference(_lastUpdateTime!) > _updateDebounceTime) {
      _lastUpdateTime = now;
      notifyListeners();
    }
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

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _currentState = QuotesState.error;
    _isUploading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
