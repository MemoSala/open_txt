// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum TABLE { users }

enum Users { name, password, photo }

class User {
  final String name, _password;
  final String? photo;

  User(this._password, {required this.name, required this.photo});

  String get password => _password;
}

mixin SQLTools {
  String integer = 'INTEGER';
  String text = 'TEXT';
  String float = 'REAL';
  //----------------------
  String create = 'CREATE TABLE';
  String alter = 'ALTER TABLE';
  String addC = 'ADD COLUMN';
  //----------------------
  String vNull = 'NULL';
  String vNutNull = 'NOT NULL';
  String primaryKey = "PRIMARY KEY";
  String autoincrement = 'AUTOINCREMENT';
}

class SqlDB with SQLTools {
  static Database? _database;

  Future<Database?> get database async {
    _database ??= await _intialDb();
    return _database;
  }

  Future<Database> _intialDb() async {
    String databasePath = await getDatabasesPath(); // Path Folder DB
    String path = join(databasePath, 'sql.db'); // Create Path DB
    Database mydb = await openDatabase(
      path,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      version: 1,
    );
    return mydb;
  }

  void _createDB(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
      $create '${TABLE.users.name}' (
        '${Users.name.name}' $text $vNutNull $primaryKey ,
        '${Users.password.name}' $text $vNutNull,
        '${Users.photo.name}' $text $vNull
      );
    ''');
    await batch.commit();
  }

  void _upgradeDB(Database db, int oldVersion, int newVersion) async {}

//--SQL-------------------------------------------------------------------------
  //SELECT * FOR animes
  Future<List<Map<String, Object?>>> readData({
    required String select,
    required TABLE from,
  }) async {
    Database? mydb = await database;
    List<Map<String, Object?>> listMap =
        await mydb!.rawQuery('SELECT $select FROM ${from.name};');
    return listMap;
  }

  //INSERT INTO animes(...) VALUES(...)
  Future<int> insertData({
    required Map<String, String?> intoValues,
    required TABLE from,
  }) async {
    String into = "";
    String values = "";
    intoValues.forEach((key, value) {
      into += '"$key",';
      values += value == null ? 'null,' : '"$value",';
    });
    into = into.substring(0, into.length - 1);
    values = values.substring(0, values.length - 1);
    Database? mydb = await database;
    int listMap = await mydb!.rawInsert(
      "INSERT INTO ${from.name}( $into ) VALUES( $values )",
    );
    return listMap;
  }

  //DElETE FROM animes WHERE ...;",
  Future<int> updateData({
    required TABLE from,
    required Map<String, String?> setValues,
    required String where,
  }) async {
    String values = "";
    setValues.forEach((key, value) {
      values += value == null ? '"$key" = null,' : '"$key" = "$value",';
    });
    values = values.substring(0, values.length - 1);
    Database? mydb = await database;
    int listMap =
        await mydb!.rawUpdate("UPDATE ${from.name} SET $values WHERE $where");
    return listMap;
  }

  //DElETE FROM animes WHERE ...;",
  Future<int> deleteData({
    required TABLE from,
    required String where,
  }) async {
    Database? mydb = await database;
    int listMap =
        await mydb!.rawDelete("DElETE FROM ${from.name} WHERE $where;");
    return listMap;
  }

//--Super SQL-------------------------------------------------------------------
  Future<List<Map<String, Object?>>> superReadData({
    required TABLE from,
  }) async {
    Database? mydb = await database;
    List<Map<String, Object?>> listMap = await mydb!.query(from.name);
    return listMap;
  }

  Future<int> superInsertData({
    required TABLE from,
    required Map<String, String?> intoValues,
  }) async {
    Database? mydb = await database;
    int listMap = await mydb!.insert(from.name, intoValues);
    return listMap;
  }

  Future<int> superUpdateData({
    required TABLE from,
    required Map<String, String?> setValues,
    required String where,
  }) async {
    Database? mydb = await database;
    int listMap = await mydb!.update(from.name, setValues, where: where);
    return listMap;
  }

  Future<int> superDeleteData({
    required TABLE from,
    required String where,
  }) async {
    Database? mydb = await database;
    int listMap = await mydb!.delete(from.name, where: where);
    return listMap;
  }

//--DB--------------------------------------------------------------------------
  deleteDB() async {
    String databasePath = await getDatabasesPath(); // Path Folder DB
    String path = join(databasePath, 'sql.db'); // Create Path DB
    await deleteDatabase(path);
  }
}
