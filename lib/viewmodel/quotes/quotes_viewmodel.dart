import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../model/quotes/quotes_model.dart';
import '../../use_case/quotes/quote_upload_use_case.dart';

enum QuotesState { loading, empty, loaded, error }

class QuotesViewModel extends ChangeNotifier {
  final QuoteUploadUseCase _quoteUploadUseCase;

  QuotesState _currentState = QuotesState.empty;
  bool _isUploading = false;
  String? _errorMessage;

  // Lista de quotes
  final List<QuotesModel> _quotes = [];
  final List<QuotesModel> _filteredQuotes = [];
  String _searchQuery = '';

  // Construtor
  QuotesViewModel(this._quoteUploadUseCase) {
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
  Future<void> _loadQuotes() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _quoteUploadUseCase.getQuotes();

      result.when(
        ok: (response) {
          _quotes.clear();
          _quotes.addAll(
            response.uploads.map((upload) => QuotesModel.fromPdfUpload(upload)),
          );
          _updateState();
        },
        error: (error) {
          _setError('Failed to load quotes: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Unexpected error loading quotes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona e faz upload de um arquivo PDF
  Future<void> pickFile() async {
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

        // Validações básicas
        if (!await _validateFile(file)) {
          return;
        }

        // Faz upload do arquivo
        await _uploadPdfFile(file, fileName);
      } else {
        // Usuário cancelou
        _updateState();
        debugPrint('File selection cancelled');
      }
    } catch (e) {
      _setError('Error selecting file: $e');
      debugPrint('Error in pickFile: $e');
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

      return true;
    } catch (e) {
      _setError('Error validating file: $e');
      return false;
    }
  }

  /// Faz upload do arquivo PDF
  Future<void> _uploadPdfFile(File file, String fileName) async {
    try {
      _setUploading(true);
      _clearError();

      final result = await _quoteUploadUseCase.uploadQuote(file);

      result.when(
        ok: (response) {
          // Cria um novo quote com os dados da resposta
          final newQuote = QuotesModel.fromPdfUpload(response.upload);

          // Adiciona à lista
          _quotes.add(newQuote);
          _updateState();

          debugPrint('Quote uploaded successfully: ${newQuote.titulo}');
          debugPrint('Status: ${newQuote.statusDisplay}');

          // Se o status for pending, inicia polling para acompanhar o progresso
          if (newQuote.isPending) {
            _startStatusPolling(newQuote.id);
          }
        },
        error: (error) {
          _setError('Upload failed: ${error.toString()}');
          debugPrint('Upload error: $error');
        },
      );
    } catch (e) {
      _setError('Unexpected error during upload: $e');
      debugPrint('Unexpected upload error: $e');
    } finally {
      _setUploading(false);
    }
  }

  /// Inicia polling do status do upload
  Future<void> _startStatusPolling(String quoteId) async {
    try {
      final uploadId = int.tryParse(quoteId);
      if (uploadId == null) return;

      final result = await _quoteUploadUseCase.pollQuoteStatus(uploadId);

      result.when(
        ok: (upload) {
          // Atualiza o quote na lista com o novo status
          final index = _quotes.indexWhere((q) => q.id == quoteId);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromPdfUpload(upload);
            _updateState();
            notifyListeners();

            debugPrint('Quote status updated: ${upload.status.value}');
          }
        },
        error: (error) {
          debugPrint('Status polling failed: $error');
          // Não mostra erro para o usuário, apenas log
        },
      );
    } catch (e) {
      debugPrint('Error in status polling: $e');
    }
  }

  /// Remove um quote
  Future<void> removeQuote(String id) async {
    try {
      final uploadId = int.tryParse(id);
      if (uploadId == null) {
        _setError('Invalid quote ID');
        return;
      }

      final result = await _quoteUploadUseCase.deleteQuote(uploadId);

      result.when(
        ok: (_) {
          _quotes.removeWhere((quote) => quote.id == id);
          _updateState();
          notifyListeners();
          debugPrint('Quote deleted successfully');
        },
        error: (error) {
          _setError('Failed to delete quote: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Unexpected error deleting quote: $e');
    }
  }

  /// Renomeia um quote
  Future<void> renameQuote(String id, String newTitle) async {
    try {
      final uploadId = int.tryParse(id);
      if (uploadId == null) {
        _setError('Invalid quote ID');
        return;
      }

      final result = await _quoteUploadUseCase.updateQuote(uploadId, newTitle);

      result.when(
        ok: (upload) {
          final index = _quotes.indexWhere((quote) => quote.id == id);
          if (index != -1) {
            _quotes[index] = QuotesModel.fromPdfUpload(upload);
            _filterQuotes(); // Re-apply filter after rename
            notifyListeners();
            debugPrint('Quote renamed successfully');
          }
        },
        error: (error) {
          _setError('Failed to rename quote: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Unexpected error renaming quote: $e');
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
  Future<void> refresh() async {
    await _loadQuotes();
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
