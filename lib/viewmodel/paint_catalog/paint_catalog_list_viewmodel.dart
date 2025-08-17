import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/paint_catalog_model.dart';
import '../../domain/repository/paint_catalog_repository.dart';

class PaintCatalogListViewModel extends ChangeNotifier {
  final IPaintCatalogRepository _paintCatalogRepository;

  List<PaintBrand> _brands = [];
  List<PaintBrand> _popularBrands = [];
  List<PaintColor> _colors = [];
  CatalogOverview? _overview;
  bool _isLoading = false;
  String? _error;
  String? _currentUsage;
  String? _selectedBrandKey;

  PaintCatalogListViewModel(this._paintCatalogRepository);

  // Getters
  List<PaintBrand> get brands => _brands;
  List<PaintBrand> get popularBrands => _popularBrands;
  List<PaintColor> get colors => _colors;
  CatalogOverview? get overview => _overview;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUsage => _currentUsage;
  String? get selectedBrandKey => _selectedBrandKey;

  /// Carrega a visão geral do catálogo
  Future<void> loadOverview() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getOverview();
      if (result is Ok) {
        _overview = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao carregar visão geral do catálogo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega todas as marcas
  Future<void> loadBrands() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getBrands();
      if (result is Ok) {
        _brands = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao carregar marcas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega marcas populares
  Future<void> loadPopularBrands() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getPopularBrands();
      if (result is Ok) {
        _popularBrands = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao carregar marcas populares: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega cores de uma marca
  Future<void> loadBrandColors(String brandKey, {String? usage}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getBrandColors(
        brandKey,
        usage: usage,
      );
      if (result is Ok) {
        _colors = result.asOk.value;
        _currentUsage = usage;
        _selectedBrandKey = brandKey;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao carregar cores da marca: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca cores
  Future<void> searchColors({
    String? query,
    String? brand,
    int? limit,
    int? offset,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.searchColors(
        query: query,
        brand: brand,
        limit: limit,
        offset: offset,
      );
      if (result is Ok) {
        _colors = result.asOk.value.colors;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao buscar cores: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca cores por nome
  Future<void> searchColorsByName(String searchTerm) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.searchColorsByName(searchTerm);
      if (result is Ok) {
        _colors = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao buscar cores por nome: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém cores filtradas por uso
  Future<void> getColorsByUsage(String brandKey, String usage) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getColorsByUsage(
        brandKey,
        usage,
      );
      if (result is Ok) {
        _colors = result.asOk.value;
        _currentUsage = usage;
        _selectedBrandKey = brandKey;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao obter cores por uso: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa a lista de cores
  void clearColors() {
    _colors.clear();
    _currentUsage = null;
    _selectedBrandKey = null;
    notifyListeners();
  }

  /// Limpa todos os dados
  void clearAll() {
    _brands.clear();
    _popularBrands.clear();
    _colors.clear();
    _overview = null;
    _currentUsage = null;
    _selectedBrandKey = null;
    _clearError();
    notifyListeners();
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
