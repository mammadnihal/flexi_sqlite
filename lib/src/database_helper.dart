import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'schema.dart';

class DatabaseHelper {
  final String dbName;
  final List<TableDefinition> tables;
  final int version;

  Database? _db;

  DatabaseHelper({
    required this.dbName,
    required this.tables,
    this.version = 1,
  });

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB(dbName);
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return openDatabase(
      path,
      version: version,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    for (final table in tables) {
      await db.execute(table.toSql());
    }
  }

  Future<void> closeDatabase() async {
    await _db?.close();
    _db = null;
  }

  Future<void> resetDatabase() async {
    await closeDatabase();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    final db = await database;
    return db.query(tableName);
    }

  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(tableName, data);
  }

  Future<int> update(
    String tableName,
    Map<String, dynamic> data, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.update(tableName, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String tableName, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(tableName, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql) async {
    final db = await database;
    return db.rawQuery(sql);
  }
}
