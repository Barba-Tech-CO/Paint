import '../../model/material_models/material_model.dart';

/// Utilitários para mapear campos de materiais extraídos para MaterialModel
class MaterialMapper {
  /// Mapeia categoria do material extraído para tipo de material
  static MaterialType mapCategoryToType(String? category) {
    if (category == null) return MaterialType.interior;

    switch (category.toLowerCase()) {
      case 'exterior':
        return MaterialType.exterior;
      case 'interior':
      default:
        return MaterialType.interior;
    }
  }

  /// Mapeia nota de qualidade do material extraído para qualidade de material
  static MaterialQuality mapQualityGradeToQuality(String? qualityGrade) {
    if (qualityGrade == null) return MaterialQuality.standard;

    switch (qualityGrade.toUpperCase()) {
      case 'A':
        return MaterialQuality.premium;
      case 'B':
        return MaterialQuality.high;
      case 'C':
        return MaterialQuality.standard;
      case 'D':
      case 'E':
      case 'F':
        return MaterialQuality.economic;
      default:
        return MaterialQuality.standard;
    }
  }
}
