import 'package:flutter/foundation.dart';
import '../../model/models.dart';
import '../../domain/repository/material_repository.dart';

class MaterialListViewModel extends ChangeNotifier {
  final IMaterialRepository _materialRepository;
  final List<MaterialModel> _selectedMaterials = [];
  final List<String> _availableBrands = [];
  List<MaterialModel> _materials = [];

  MaterialFilter _currentFilter = MaterialFilter();
  MaterialStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  MaterialListViewModel(this._materialRepository);

  // Getters
  List<MaterialModel> get materials => _materials;
  List<String> get availableBrands => _availableBrands;
  MaterialFilter get currentFilter => _currentFilter;
  MaterialStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  int get selectedCount => _selectedMaterials.length;
  bool get hasFilters => _currentFilter.hasFilters;

  /// Carrega todos os materiais
  Future<void> loadMaterials() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _materialRepository.getAllMaterials();
      result.when(
        ok: (materials) {
          _materials = materials;
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

  /// Aplica filtros aos materiais
  Future<void> applyFilter(MaterialFilter filter) async {
    _setLoading(true);
    _clearError();
    _currentFilter = filter;

    try {
      final result = await _materialRepository.getMaterialsWithFilter(filter);
      result.when(
        ok: (materials) {
          _materials = materials;
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
      notifyListeners();
    }
  }

  /// Remove a seleção de um material
  void unselectMaterial(MaterialModel material) {
    _selectedMaterials.remove(material);
    notifyListeners();
  }

  /// Verifica se um material está selecionado
  bool isMaterialSelected(MaterialModel material) {
    return _selectedMaterials.contains(material);
  }

  /// Limpa todas as seleções
  void clearSelection() {
    _selectedMaterials.clear();
    notifyListeners();
  }

  /// Seleciona todos os materiais visíveis
  void selectAllVisible() {
    for (final material in _materials) {
      if (!_selectedMaterials.contains(material)) {
        _selectedMaterials.add(material);
      }
    }
    notifyListeners();
  }

  /// Obtém o total do carrinho
  double get totalPrice {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) => sum + material.price,
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
    ]);
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
