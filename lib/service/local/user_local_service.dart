import 'package:sqflite/sqflite.dart';

import '../../model/user_model.dart';
import '../database_service.dart';

class UserLocalService {
  final DatabaseService _dbService;

  UserLocalService(this._dbService);

  Future<int?> saveUser(UserModel user) async {
    final db = await _dbService.database;
    await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return user.id;
  }

  Future<UserModel?> getUser(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<void> deleteUser(int id) async {
    final db = await _dbService.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _dbService.database;
    await db.delete('users');
  }

  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'email_verified_at': user.emailVerifiedAt?.toIso8601String(),
      'remember_token': null,
      'ghl_business_id': user.ghlBusinessId,
      'ghl_phone': user.ghlPhone,
      'ghl_website': user.ghlWebsite,
      'ghl_address': user.ghlAddress,
      'ghl_city': user.ghlCity,
      'ghl_state': user.ghlState,
      'ghl_postal_code': user.ghlPostalCode,
      'ghl_country': user.ghlCountry,
      'ghl_description': user.ghlDescription,
      'created_at': user.createdAt?.toIso8601String(),
      'updated_at': user.updatedAt?.toIso8601String(),
    };
  }

  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateTime.parse(map['email_verified_at'])
          : null,
      ghlLocationId: null, // Not stored in local DB
      ghlBusinessId: map['ghl_business_id'],
      ghlPhone: map['ghl_phone'],
      ghlWebsite: map['ghl_website'],
      ghlAddress: map['ghl_address'],
      ghlCity: map['ghl_city'],
      ghlState: map['ghl_state'],
      ghlPostalCode: map['ghl_postal_code'],
      ghlCountry: map['ghl_country'],
      ghlDescription: map['ghl_description'],
      isGhlUser: false, // Default value for local
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
