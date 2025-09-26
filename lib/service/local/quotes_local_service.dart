import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../model/quotes_data/quote_model.dart';
import '../../model/quotes_data/quote_status.dart';
import '../database_service.dart';

class QuotesLocalService {
  final DatabaseService _dbService;

  QuotesLocalService(this._dbService);

  Future<int> saveQuote(QuoteModel quote) async {
    final db = await _dbService.database;
    await db.insert(
      'quotes',
      _quoteToMap(quote),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return quote.id;
  }

  Future<QuoteModel?> getQuote(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('quotes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToQuote(maps.first);
    }
    return null;
  }

  Future<List<QuoteModel>> getAllQuotes() async {
    final db = await _dbService.database;
    final maps = await db.query('quotes', orderBy: 'created_at DESC');
    return maps.map(_mapToQuote).toList();
  }

  Future<void> updateQuote(QuoteModel quote) async {
    final db = await _dbService.database;
    await db.update(
      'quotes',
      _quoteToMap(quote),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
  }

  Future<void> deleteQuote(int id) async {
    final db = await _dbService.database;
    await db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markQuoteAsSynced(int id) async {
    final db = await _dbService.database;
    await db.update(
      'quotes',
      {
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _quoteToMap(QuoteModel quote) {
    return {
      'id': quote.id,
      'user_id': quote.userId,
      'original_name': quote.originalName,
      'display_name': quote.displayName,
      'file_path': quote.filePath,
      'r2_url': quote.r2Url,
      'file_hash': quote.fileHash,
      'status': quote.status.name,
      'materials_extracted': quote.materialsExtracted,
      'extraction_metadata': quote.extractionMetadata != null
          ? json.encode(quote.extractionMetadata)
          : null,
      'error_message': quote.errorMessage,
      'created_at': quote.createdAt.toIso8601String(),
      'updated_at': quote.updatedAt.toIso8601String(),
      'is_synced': 1,
      'sync_status': 'synced',
    };
  }

  QuoteModel _mapToQuote(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['id'],
      userId: map['user_id'],
      originalName: map['original_name'],
      displayName: map['display_name'],
      filePath: map['file_path'],
      r2Url: map['r2_url'],
      fileHash: map['file_hash'],
      status: QuoteStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => QuoteStatus.pending,
      ),
      materialsExtracted: map['materials_extracted'] ?? 0,
      extractionMetadata: map['extraction_metadata'] != null
          ? json.decode(map['extraction_metadata']) as Map<String, dynamic>
          : null,
      errorMessage: map['error_message'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
