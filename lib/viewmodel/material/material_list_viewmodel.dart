import 'package:flutter/foundation.dart';

import '../../domain/repository/material_repository.dart';
import '../../model/material_models/material_model.dart';
import '../../model/material_models/material_stats_model.dart';

class MaterialListViewModel extends ChangeNotifier {
  final IMaterialRepository _materialRepository;
  final List<MaterialModel> _selectedMaterials = [];
  final Map<MaterialModel, int> _materialQuantities = {};
  final List<String> _availableBrands = [];
  List<MaterialModel> _materials = [];

  MaterialFilter _currentFilter = MaterialFilter();
  MaterialStatsModel? _stats;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _error;

  MaterialListViewModel(this._materialRepository);

  // Getters
  List<MaterialModel> get materials => _materials;
  List<String> get availableBrands => _availableBrands;
  MaterialFilter get currentFilter => _currentFilter;
  MaterialStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  String? get error => _error;
  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  int get selectedCount => _selectedMaterials.length;
  bool get hasFilters => _currentFilter.hasFilters;
  Map<MaterialModel, int> get materialQuantities => _materialQuantities;

  /// Carrega todos os materiais (primeira página)
  Future<void> loadMaterials() async {
    _setLoading(true);
    _clearError();
    _currentPage = 1;
    _hasMoreData = true;

    try {
      final result = await _materialRepository.getAllMaterials(
        limit: _pageSize,
        offset: 0,
      );

      result.when(
        ok: (materials) {
          _materials = materials;

          // Se retornou menos que o pageSize, não há mais dados
          if (materials.length < _pageSize) {
            _hasMoreData = false;
          }

          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao carregar materiais: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar materiais: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega mais materiais (próxima página)
  Future<void> loadMoreMaterials() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _setLoadingMore(true);
    _clearError();

    try {
      final nextPage = _currentPage + 1;
      final offset = (nextPage - 1) * _pageSize;

      final result = await _materialRepository.getAllMaterials(
        limit: _pageSize,
        offset: offset,
      );

      result.when(
        ok: (newMaterials) {
          if (newMaterials.isNotEmpty) {
            _materials.addAll(newMaterials);
            _currentPage = nextPage;

            // Se retornou menos que o pageSize, não há mais dados
            if (newMaterials.length < _pageSize) {
              _hasMoreData = false;
            }
          } else {
            _hasMoreData = false;
          }

          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao carregar mais materiais: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar mais materiais: $e');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Carrega marcas disponíveis
  Future<void> loadAvailableBrands() async {
    try {
      final result = await _materialRepository.getAvailableBrands();
      result.when(
        ok: (brands) {
          _availableBrands.clear();
          _availableBrands.addAll(brands);
          notifyListeners();
        },
        error: (error) {
          // Não mostra erro para marcas, apenas log silencioso
        },
      );
    } catch (e) {
      // Erro inesperado ao carregar marcas - falha silenciosa
    }
  }

  /// Aplica filtros aos materiais (primeira página)
  Future<void> applyFilter(MaterialFilter filter) async {
    _setLoading(true);
    _clearError();
    _currentFilter = filter;
    _currentPage = 1;
    _hasMoreData = true;

    try {
      final result = await _materialRepository.getMaterialsWithFilter(
        filter,
        limit: _pageSize,
        offset: 0,
      );
      result.when(
        ok: (materials) {
          _materials = materials;

          // Se retornou menos que o pageSize, não há mais dados
          if (materials.length < _pageSize) {
            _hasMoreData = false;
          }

          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao filtrar materiais: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao filtrar materiais: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega estatísticas dos materiais
  Future<void> loadStats() async {
    try {
      final result = await _materialRepository.getMaterialStats();
      result.when(
        ok: (stats) {
          _stats = stats;
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao carregar estatísticas: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar estatísticas: $e');
    }
  }

  /// Busca materiais por termo
  Future<void> searchMaterials(String searchTerm) async {
    final filter = _currentFilter.copyWith(searchTerm: searchTerm);
    await applyFilter(filter);
  }

  /// Filtrar por marca
  Future<void> filterByBrand(String? brand) async {
    final filter = _currentFilter.copyWith(brand: brand);
    await applyFilter(filter);
  }

  /// Filtrar por tipo
  Future<void> filterByType(MaterialType? type) async {
    final filter = _currentFilter.copyWith(type: type);
    await applyFilter(filter);
  }

  /// Filtrar por qualidade
  Future<void> filterByQuality(MaterialQuality? quality) async {
    final filter = _currentFilter.copyWith(quality: quality);
    await applyFilter(filter);
  }

  /// Filtrar por acabamento
  Future<void> filterByFinish(MaterialFinish? finish) async {
    final filter = _currentFilter.copyWith(finish: finish);
    await applyFilter(filter);
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    _currentFilter = MaterialFilter();
    await loadMaterials();
  }

  /// Seleciona um material
  void selectMaterial(MaterialModel material) {
    if (!_selectedMaterials.contains(material)) {
      _selectedMaterials.add(material);
      _materialQuantities[material] = 1; // Default quantity is 1
      notifyListeners();
    }
  }

  /// Remove a seleção de um material
  void unselectMaterial(MaterialModel material) {
    _selectedMaterials.remove(material);
    _materialQuantities.remove(material);
    notifyListeners();
  }

  /// Aumenta a quantidade de um material
  void increaseQuantity(MaterialModel material) {
    if (_selectedMaterials.contains(material)) {
      final currentQuantity = _materialQuantities[material] ?? 1;
      // Garantir que a quantidade nunca seja menor que 1
      final newQuantity = (currentQuantity < 1 ? 1 : currentQuantity) + 1;
      _materialQuantities[material] = newQuantity;
      notifyListeners();
    }
  }

  /// Diminui a quantidade de um material
  void decreaseQuantity(MaterialModel material) {
    if (_selectedMaterials.contains(material)) {
      final currentQuantity = _materialQuantities[material] ?? 1;
      // Garantir que a quantidade nunca seja menor que 1
      if (currentQuantity > 1) {
        _materialQuantities[material] = currentQuantity - 1;
        notifyListeners();
      }
    }
  }

  /// Obtém a quantidade de um material
  int getQuantity(MaterialModel material) {
    final quantity = _materialQuantities[material] ?? 1;
    // Garantir que a quantidade retornada nunca seja menor que 1
    return quantity < 1 ? 1 : quantity;
  }

  /// Define a quantidade de um material com validação
  void setQuantity(MaterialModel material, int quantity) {
    if (_selectedMaterials.contains(material)) {
      // Garantir que a quantidade nunca seja menor que 1
      _materialQuantities[material] = quantity < 1 ? 1 : quantity;
      notifyListeners();
    }
  }

  /// Verifica se um material está selecionado
  bool isMaterialSelected(MaterialModel material) {
    return _selectedMaterials.contains(material);
  }

  /// Limpa todas as seleções
  void clearSelection() {
    _selectedMaterials.clear();
    _materialQuantities.clear();
    notifyListeners();
  }

  /// Seleciona todos os materiais visíveis
  void selectAllVisible() {
    for (final material in _materials) {
      if (!_selectedMaterials.contains(material)) {
        _selectedMaterials.add(material);
        _materialQuantities[material] = 1; // Default quantity is 1
      }
    }
    notifyListeners();
  }

  /// Obtém o total do carrinho
  double get totalPrice {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) {
        final quantity = _materialQuantities[material] ?? 1;
        // Garantir que a quantidade usada no cálculo nunca seja menor que 1
        final validQuantity = quantity < 1 ? 1 : quantity;
        return sum + (material.price * validQuantity);
      },
    );
  }

  /// Recarrega dados
  Future<void> refresh() async {
    _clearError();
    if (_currentFilter.hasFilters) {
      await applyFilter(_currentFilter);
    } else {
      await loadMaterials();
    }
  }

  /// Inicializa o ViewModel
  Future<void> initialize() async {
    await Future.wait([
      loadMaterials(),
      loadStats(),
      loadAvailableBrands(),
    ]);
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
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
