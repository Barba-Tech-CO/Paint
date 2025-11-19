import '../model/zones/zone_add_data_model.dart';
import '../model/projects/project_card_model.dart';
import '../utils/command/command.dart';

abstract class IZonesService {
  /// Lista todas as zonas (dados locais)
  List<ProjectCardModel> getZones();

  /// Obtém uma zona específica por ID (dados locais)
  ProjectCardModel? getZone(int zoneId);

  /// Extrai caminhos das fotos de uma zona
  List<String> extractPhotoPaths(ProjectCardModel zone);

  /// Limpa todas as zonas (para reset)
  void clearZones();

  /// Obtém o próximo ID disponível
  int getNextId();

  // Commands
  Command0<List<ProjectCardModel>> get loadZonesCommand;
  Command1<ProjectCardModel, ZoneAddDataModel> get addZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>> get updateZoneCommand;
  Command1<bool, int> get deleteZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>> get renameZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>> get addPhotosCommand;
  Command1<ProjectCardModel, Map<String, dynamic>> get removePhotoCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>
  get updateZoneDimensionsCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>
  get updateZoneSurfaceAreasCommand;
}
