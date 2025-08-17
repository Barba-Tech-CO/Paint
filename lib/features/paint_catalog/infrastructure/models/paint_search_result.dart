import 'paint_color.dart';

class PaintSearchResult {
  final List<PaintColor> colors;
  final int total;
  final int? limit;
  final int? offset;

  PaintSearchResult({
    required this.colors,
    required this.total,
    this.limit,
    this.offset,
  });

  factory PaintSearchResult.fromJson(Map<String, dynamic> json) {
    final colorsList = json['colors'] as List<dynamic>? ?? [];
    return PaintSearchResult(
      colors: colorsList.map((color) => PaintColor.fromJson(color)).toList(),
      total: json['total'] ?? 0,
      limit: json['limit'],
      offset: json['offset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colors': colors.map((color) => color.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}
