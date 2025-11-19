import 'package:flutter/foundation.dart';

/// Service to manage the current location ID in memory
class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  String? _currentLocationId;
  String? _currentLocationName;

  /// Gets the current location ID
  String? get currentLocationId => _currentLocationId;

  /// Gets the current location name
  String? get currentLocationName => _currentLocationName;

  /// Checks if a location ID is set
  bool get hasLocationId =>
      _currentLocationId != null && _currentLocationId!.isNotEmpty;

  /// Sets the current location ID and notifies listeners
  void setLocationId(String locationId, {String? locationName}) {
    _currentLocationId = locationId;
    _currentLocationName = locationName;
    notifyListeners();
  }

  /// Clears the current location ID and notifies listeners
  void clearLocationId() {
    _currentLocationId = null;
    _currentLocationName = null;
    notifyListeners();
  }

  /// Updates the location name without changing the ID
  void updateLocationName(String locationName) {
    _currentLocationName = locationName;
    notifyListeners();
  }

  /// Gets a formatted location string for display
  String get locationDisplayString {
    if (_currentLocationName != null && _currentLocationName!.isNotEmpty) {
      return _currentLocationName!;
    }
    if (_currentLocationId != null && _currentLocationId!.isNotEmpty) {
      return 'Location: ${_currentLocationId!.substring(0, 8)}...';
    }
    return 'No location set';
  }
}
