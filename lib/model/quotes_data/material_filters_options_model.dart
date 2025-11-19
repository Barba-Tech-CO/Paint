class MaterialFiltersOptions {
  final List<String> brands;
  final List<String> ambients;
  final List<String> finishes;
  final List<String> qualities;

  MaterialFiltersOptions({
    required this.brands,
    required this.ambients,
    required this.finishes,
    required this.qualities,
  });

  factory MaterialFiltersOptions.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['success'] == null) {
      throw Exception('Missing required field: success');
    }

    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Missing required field: data');
    }

    final filters = data['filters'] as Map<String, dynamic>?;
    if (filters == null) {
      throw Exception('Missing required field: data.filters');
    }

    return MaterialFiltersOptions(
      brands: List<String>.from(filters['brands'] as List? ?? []),
      ambients: List<String>.from(filters['ambients'] as List? ?? []),
      finishes: List<String>.from(filters['finishes'] as List? ?? []),
      qualities: List<String>.from(filters['qualities'] as List? ?? []),
    );
  }
}
