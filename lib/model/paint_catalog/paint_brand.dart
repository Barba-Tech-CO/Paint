class PaintBrand {
  final String key;
  final String name;
  final String? description;
  final String? logoUrl;
  final bool isPopular;

  PaintBrand({
    required this.key,
    required this.name,
    this.description,
    this.logoUrl,
    this.isPopular = false,
  });

  factory PaintBrand.fromJson(Map<String, dynamic> json) {
    return PaintBrand(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'is_popular': isPopular,
    };
  }
}
