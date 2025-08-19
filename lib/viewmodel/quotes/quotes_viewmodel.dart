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

  // Getters
  QuotesState get currentState => _currentState;
  List<QuotesModel> get quotes => List.unmodifiable(_quotes);
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
        String? filePath = result.files.single.path;
        String? fileName = result.files.single.name;

        if (filePath != null) {
          // Cria um novo quote
          final newQuote = QuotesModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            titulo: fileName,
            dateUpload: DateTime.now(),
          );

          // Adiciona à lista
          _quotes.add(newQuote);
          _updateState();

          print('Quote adicionado: ${newQuote.titulo}');
        }
      } else {
        // Usuário cancelou - volta ao estado anterior
        _updateState();
        print('Seleção de arquivo cancelada');
      }
    } catch (e) {
      _setError('Erro ao fazer upload do arquivo: $e');
      print('Erro no upload: $e');
    } finally {
      _setLoading(false);
    }
  }

  void removeQuote(String id) {
    _quotes.removeWhere((quote) => quote.id == id);
    _updateState();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _updateState();
  }
}
