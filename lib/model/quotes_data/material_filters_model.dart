class MaterialFilters {
  final String? brand;
  final String? ambient;
  final String? finish;
  final List<String>? quality;
  final String? search;
  final String sortBy;
  final String sortOrder;
  final int page;

  MaterialFilters({
    this.brand,
    this.ambient,
    this.finish,
    this.quality,
    this.search,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (brand != null && brand!.isNotEmpty) params['brand'] = brand;
    if (ambient != null && ambient!.isNotEmpty) params['ambient'] = ambient;
    if (finish != null && finish!.isNotEmpty) params['finish'] = finish;
    if (search != null && search!.isNotEmpty) params['search'] = search;

    // Qualidade pode ser múltipla (array) - formato correto da API
    if (quality != null && quality!.isNotEmpty) {
      if (quality!.length == 1) {
        params['quality'] = quality!.first;
      } else {
        for (int i = 0; i < quality!.length; i++) {
          params['quality[]'] = quality![i];
        }
      }
    }

    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    params['page'] = page.toString();

    return params;
  }

  MaterialFilters copyWith({
    String? brand,
    String? ambient,
    String? finish,
    List<String>? quality,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? page,
  }) {
    return MaterialFilters(
      brand: brand ?? this.brand,
      ambient: ambient ?? this.ambient,
      finish: finish ?? this.finish,
      quality: quality ?? this.quality,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
    );
  }

  bool get isEmpty =>
      brand == null &&
      ambient == null &&
      finish == null &&
      (quality == null || quality!.isEmpty) &&
      (search == null || search!.isEmpty);
}
