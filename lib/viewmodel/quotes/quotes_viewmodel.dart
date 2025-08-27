import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../model/quotes/quotes_model.dart';

enum QuotesState { loading, empty, loaded, error }

class QuotesViewModel extends ChangeNotifier {
  QuotesState _currentState = QuotesState.empty;
  bool _isUploading = false;
  String? _errorMessage;

  // Lista de quotes
  final List<QuotesModel> _quotes = [];
  final List<QuotesModel> _filteredQuotes = [];
  String _searchQuery = '';

  // Getters
  QuotesState get currentState => _currentState;
  List<QuotesModel> get quotes => _searchQuery.isEmpty
      ? List.unmodifiable(_quotes)
      : List.unmodifiable(_filteredQuotes);
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasQuotes => _quotes.isNotEmpty;

  // Construtor - verifica se já tem quotes
  QuotesViewModel() {
    _updateState();
  }

  void _updateState() {
    if (_quotes.isEmpty) {
      _currentState = QuotesState.empty;
    } else {
      _currentState = QuotesState.loaded;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isUploading = loading;
    if (loading) {
      _currentState = QuotesState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _currentState = QuotesState.error;
    _isUploading = false;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      _setLoading(true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String? fileName = result.files.single.name;

        // Cria um novo quote
        final newQuote = QuotesModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: fileName,
          dateUpload: DateTime.now(),
        );

        // Adiciona à lista
        _quotes.add(newQuote);
        _updateState();

        debugPrint('Quote adicionado: ${newQuote.titulo}');
      } else {
        // Usuário cancelou - volta ao estado anterior
        _updateState();
        debugPrint('Seleção de arquivo cancelada');
      }
    } catch (e) {
      _setError('Erro ao fazer upload do arquivo: $e');
      debugPrint('Erro no upload: $e');
    } finally {
      _setLoading(false);
    }
  }

  void removeQuote(String id) {
    _quotes.removeWhere((quote) => quote.id == id);
    _updateState();
    notifyListeners();
  }

  void renameQuote(String id, String newTitle) {
    final index = _quotes.indexWhere((quote) => quote.id == id);
    if (index != -1) {
      final oldQuote = _quotes[index];
      _quotes[index] = QuotesModel(
        id: oldQuote.id,
        titulo: newTitle,
        dateUpload: oldQuote.dateUpload,
      );
      _filterQuotes(); // Re-apply filter after rename
      notifyListeners();
    }
  }

  void searchQuotes(String query) {
    _searchQuery = query.toLowerCase();
    _filterQuotes();
    notifyListeners();
  }

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

  void clearError() {
    _errorMessage = null;
    _updateState();
  }
}
