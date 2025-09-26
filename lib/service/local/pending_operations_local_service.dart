import 'dart:convert';

import '../../utils/logger/app_logger.dart';
import '../database_service.dart';

class PendingOperationsLocalService {
  final DatabaseService _dbService;
  final AppLogger _logger;

  PendingOperationsLocalService(this._dbService, this._logger);

  Future<void> addPendingOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final db = await _dbService.database;
    await db.insert(
      'pending_operations',
      {
        'operation_type': operationType,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await _dbService.database;
    return await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
  }

  Future<void> removePendingOperation(int id) async {
    final db = await _dbService.database;
    await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetryCount(int id) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT retry_count FROM pending_operations WHERE id = ?',
      [id],
    );

    if (result.isNotEmpty) {
      final currentCount = result.first['retry_count'] as int;
      await db.update(
        'pending_operations',
        {
          'retry_count': currentCount + 1,
          'last_retry_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      _logger.warning('Pending operation not found for id=$id');
    }
  }
}
