import 'package:flutter/foundation.dart';
import '../../model/zones_card_model.dart';

class ZoneDetailViewModel extends ChangeNotifier {
  ZonesCardModel? _zone;
  bool _isLoading = false;
  String? _error;

  ZoneDetailViewModel([ZonesCardModel? zone]) {
    _zone = zone;
  }

  ZonesCardModel? get zone => _zone;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setZone(ZonesCardModel zone) {
    _zone = zone;
    notifyListeners();
  }

  Future<void> renameZone(String newName) async {
    if (_zone == null) return;
    _isLoading = true;
    notifyListeners();
    // Simulação de atualização
    _zone = _zone!.copyWith(title: newName);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteZone() async {
    // Aqui você pode implementar a lógica de remoção
    _zone = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}
