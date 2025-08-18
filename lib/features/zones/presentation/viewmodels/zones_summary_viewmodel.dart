import 'package:flutter/foundation.dart';
import '../../infrastructure/models/zones_card_model.dart';
import '../../infrastructure/models/zones_summary_model.dart';

// Placeholder viewmodel to satisfy existing widget dependencies
// This maintains the interface expected by zones_results_widget
class ZonesSummaryViewModel extends ChangeNotifier {
  ZonesSummaryModel? _summary;

  ZonesSummaryModel? get summary => _summary;

  void initialize() {
    // Placeholder implementation
  }

  void updateZonesList(List<ZonesCardModel> zones) {
    // Placeholder implementation
  }
}