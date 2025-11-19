import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

class DashboardCacheLocalService {
  final DatabaseService _dbService;

  DashboardCacheLocalService(this._dbService);

  Future<void> saveDashboardCache(
    String cacheKey,
    Map<String, dynamic> data,
  ) async {
    final db = await _dbService.database;
    await db.insert(
      'dashboard_cache',
      {
        'cache_key': cacheKey,
        'data': json.encode(data),
        'cached_at': data['cached_at'],
        'expires_at': data['expires_at'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDashboardCache(String cacheKey) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'dashboard_cache',
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
    );
    if (maps.isNotEmpty) {
      final data =
          json.decode(maps.first['data'] as String) as Map<String, dynamic>;
      return data;
    }
    return null;
  }

  Future<void> removeDashboardCache(String cacheKey) async {
    final db = await _dbService.database;
    await db.delete(
      'dashboard_cache',
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
    );
  }

  Future<void> clearExpiredDashboardCache() async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'dashboard_cache',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }
}
