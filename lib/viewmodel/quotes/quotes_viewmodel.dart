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

  // Helper methods for common operations
  Future<Result<T>> _handleUseCaseCall<T>(
    Future<Result<T>> Function() useCaseCall,
    String operation,
  ) async {
    try {
      final result = await useCaseCall();
      return result.when(
        ok: (data) => Result.ok(data),
        error: (error) {
          _setError('Failed to $operation');
          _logger.error('Error in $operation: $error', error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _setError('Unexpected error during $operation');
      _logger.error('Unexpected error in $operation: $e', e);
      return Result.error(Exception('Unexpected error'));
    }
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

  @override
  void dispose() {
    _stopAllPolling();
    super.dispose();
  }

  /// Carrega quotes existentes
  Future<Result<void>> _loadQuotes() async {
    _setLoading(true);
    _clearError();

    final result = await _handleUseCaseCall(
      () => _quoteUploadUseCase.getQuotes(),
      'load quotes',
    );

    if (result is Ok) {
      final response = result.asOk.value;
      _quotes.clear();
      if (response.quotes.isNotEmpty) {
        _quotes.addAll(
          response.quotes.map((upload) => QuotesModel.fromQuote(upload)),
        );
      }
      _updateState();
    }

    _setLoading(false);
    return result;
  }

  /// Seleciona e faz upload de um arquivo PDF
  Future<Result<void>> pickFile() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        _updateState();
        _logger.info('File selection cancelled');
        return Result.ok(null);
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      _logger.info('Selected file: $fileName');
      _logger.info('File path: ${file.path}');
      _logger.info('File size: ${await file.length()} bytes');

      final validationResult = await _validateFile(file);
      if (!validationResult) {
        return Result.error(Exception('File validation failed'));
      }

      return await _uploadPdfFile(file, fileName);
    } catch (e) {
      _setError('Error selecting file');
      _logger.error('Error in pickFile: $e', e);
      return Result.error(Exception('Unexpected error'));
    } finally {
      _setLoading(false);
    }
  }

  /// Valida o arquivo antes do upload
  Future<bool> _validateFile(File file) async {
    try {
      if (!await _validateFileExistence(file)) return false;
      if (!await _validateFileSize(file)) return false;
      if (!_validateFileExtension(file)) return false;
      if (!_validateFileName(file)) return false;
      if (!await _validateFileContent(file)) return false;

      _logger.info(
        'File validation passed. Note: Backend requires USD currency in PDF content.',
      );
      return true;
    } catch (e) {
      _setError('Error validating file');
      _logger.error('Error validating file: $e', e);
      return false;
    }
  }

  Future<bool> _validateFileExistence(File file) async {
    if (!await file.exists()) {
      _setError('Selected file does not exist');
      return false;
    }
    return true;
  }

  Future<bool> _validateFileSize(File file) async {
    final fileSize = await file.length();
    const maxSize = 25 * 1024 * 1024; // 25MB

    if (fileSize == 0) {
      _setError('Selected file is empty');
      return false;
    }

    if (fileSize > maxSize) {
      _setError('File size exceeds 25MB limit');
      return false;
    }

    return true;
  }

  bool _validateFileExtension(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension != 'pdf') {
      _setError('Only PDF files are allowed');
      return false;
    }
    return true;
  }

  bool _validateFileName(File file) {
    final fileName = file.path.split('/').last;
    if (fileName.isEmpty || fileName.length > 255) {
      _setError('Invalid file name');
      return false;
    }
    return true;
  }

  Future<bool> _validateFileContent(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _setError('Cannot read file content');
        return false;
      }

      if (bytes.length >= 4) {
        final header = String.fromCharCodes(bytes.take(4));
        if (header != '%PDF') {
          _setError('File does not appear to be a valid PDF');
          return false;
        }
      }

      return true;
    } catch (e) {
      _setError('Cannot read file');
      _logger.error('Cannot read file: $e', e);
      return false;
    }
  }

  /// Faz upload do arquivo PDF
  Future<Result<void>> _uploadPdfFile(File file, String fileName) async {
    _setUploading(true);
    _clearError();

    final result = await _handleUseCaseCall(
      () => _quoteUploadUseCase.uploadQuote(file, filename: fileName),
      'upload quote',
    );

    if (result is Ok) {
      final response = result.asOk.value;
      final newQuote = QuotesModel.fromQuote(response.quote);

      _quotes.add(newQuote);
      _updateState();

      _logger.info('Quote uploaded successfully: ${newQuote.titulo}');
      _logger.info('Status: ${newQuote.statusDisplay}');

      if (newQuote.isPending || newQuote.isProcessing) {
        _logger.info('Starting status polling for new quote: ${newQuote.id}');
        _startStatusPolling(newQuote.id);
      } else {
        _logger.info(
          'Quote ${newQuote.id} has final status: ${newQuote.statusDisplay}',
        );
      }
    }

    _setUploading(false);
    return result;
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
    _setDeleting(true);
    _deletingQuotes.add(id);
    _clearError();

    final quoteId = int.tryParse(id);
    if (quoteId == null) {
      _setDeleting(false);
      _deletingQuotes.remove(id);
      return Result.error(Exception('Invalid quote ID'));
    }

    _logger.info('Starting delete operation for quote: $id');

    final result = await _handleUseCaseCall(
      () => _quoteUploadUseCase.deleteQuote(quoteId),
      'delete quote',
    );

    if (result is Ok) {
      _quotes.removeWhere((quote) => quote.id == id);
      _stopPolling(id);
      _updateState();
      notifyListeners();
      _logger.info('Quote deleted successfully: $id');
    }

    _setDeleting(false);
    _deletingQuotes.remove(id);
    return result;
  }

  /// Renomeia um quote
  Future<Result<void>> renameQuote(String id, String newTitle) async {
    final quoteId = int.tryParse(id);
    if (quoteId == null) {
      return Result.error(Exception('Invalid quote ID'));
    }

    final result = await _handleUseCaseCall(
      () => _quoteUploadUseCase.updateQuote(quoteId, newTitle),
      'rename quote',
    );

    if (result is Ok) {
      final upload = result.asOk.value;
      final index = _quotes.indexWhere((quote) => quote.id == id);
      if (index != -1) {
        _quotes[index] = QuotesModel.fromQuote(upload);
        _filterQuotes();
        notifyListeners();
        _logger.info('Quote renamed successfully');
      }
    }

    return result;
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
}
