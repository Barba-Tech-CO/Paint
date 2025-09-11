import 'surface_item.dart';

/// Surface areas containing walls, ceiling, and trim
class SurfaceAreas {
  final List<SurfaceItem> walls;
  final List<SurfaceItem> ceiling;
  final List<SurfaceItem> trim;

  SurfaceAreas({
    required this.walls,
    required this.ceiling,
    required this.trim,
  });

  Map<String, dynamic> toJson() {
    return {
      'walls': walls.map((w) => w.toJson()).toList(),
      'ceiling': ceiling.map((c) => c.toJson()).toList(),
      'trim': trim.map((t) => t.toJson()).toList(),
    };
  }

  factory SurfaceAreas.fromJson(Map<String, dynamic> json) {
    return SurfaceAreas(
      walls:
          (json['walls'] as List<dynamic>?)
              ?.map((w) => SurfaceItem.fromJson(w))
              .toList() ??
          [],
      ceiling:
          (json['ceiling'] as List<dynamic>?)
              ?.map((c) => SurfaceItem.fromJson(c))
              .toList() ??
          [],
      trim:
          (json['trim'] as List<dynamic>?)
              ?.map((t) => SurfaceItem.fromJson(t))
              .toList() ??
          [],
    );
  }
}
