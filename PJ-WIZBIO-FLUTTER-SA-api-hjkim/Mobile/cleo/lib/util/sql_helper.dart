// ignore_for_file: constant_identifier_names

import 'package:cleo/model/test_report.dart';
import 'package:cleo/model/tester.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlHelper {
  static late Database db;
  static Future init(String dbName) async {
    // Directory directory = await getLibraryDirectory();
    debugPrint('init DB: $dbName');
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, '$dbName.db');
    db = await openDatabase(
      path,
      version: 4,
      singleInstance: true,
      onCreate: (Database db, int version) async {
        print('DB onCreate');

        await SqlTester.createTable(db);
        await SqlReport.createTable(db);
      },
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        await SqlTester.dropTable(db);
        await SqlTester.createTable(db);

        await SqlReport.dropTable(db);
        await SqlReport.createTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await SqlTester.dropTable(db);
        await SqlTester.createTable(db);

        await SqlReport.dropTable(db);
        await SqlReport.createTable(db);
      },
    );
  }
}

class SqlTester {
  static const String TABLE_NAME = 'Tester';
  static String createSql = '''CREATE TABLE $TABLE_NAME ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    birthday TEXT,
    gender INTEGER,
    macAddress TEXT
  )''';
  static String dropSql = 'DROP TABLE IF EXISTS $TABLE_NAME';

  static Future<void> createTable(Database db) async {
    await db.execute(createSql);
    print('created $TABLE_NAME table');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute(dropSql);
    print('dropped $TABLE_NAME table');
  }

  static Future<void> resetTable() async {
    await SqlHelper.db.execute(dropSql);
    await SqlHelper.db.execute(createSql);
  }

  static Future<int> insertTester(Tester tester) async {
    Map<String, Object> testerMap = tester.toSqlMap();

    return await SqlHelper.db.insert(TABLE_NAME, testerMap);
  }

  static Future deleteTesterById(int id) async {
    return await SqlHelper.db
        .delete(TABLE_NAME, where: 'id = ?', whereArgs: [id]);
  }

  static Future updateTester(int id, Tester tester) async {
    return SqlHelper.db.update(
      TABLE_NAME,
      tester.toSqlMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future loadTester({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> raws = await SqlHelper.db.query(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      orderBy: orderBy,
      columns: columns,
    );

    return raws;
  }
}

class SqlReport {
  static const String TABLE_NAME = 'Report';
  static String createSql = '''CREATE TABLE $TABLE_NAME ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    name TEXT,
    testType TEXT,
    birthday TEXT,
    gender INTEGER,
    macAddress TEXT,
    serial TEXT,
    deviceName Text,
    reportStatus INTEGER,
    startAt TEXT,
    endAt TEXT,
    result1 DOUBLE,
    result2 DOUBLE,
    result3 DOUBLE,
    rawData1 TEXT,
    rawData2 TEXT,
    rawData3 TEXT,
    rawDataTemp TEXT,
    fittingData1 TEXT,
    fittingData2 TEXT,
    fittingData3 TEXT,
    fittingDataTemp TEXT,
    fittingDataCt TEXT,
    finalResult INTEGER,
    lotNum TEXT,
    expire TEXT,
    uid Text,
    isSended boolean
  )''';

  static String dropSql = 'DROP TABLE IF EXISTS $TABLE_NAME';

  static Future<void> createTable(Database db) async {
    await db.execute(createSql);
    print('created $TABLE_NAME table');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute(dropSql);
    print('dropped $TABLE_NAME table');
  }

  static Future<void> resetTable() async {
    await SqlHelper.db.execute(dropSql);
    await SqlHelper.db.execute(createSql);
  }

  static Future<int> insertReport(TestReport report) async {
    Map<String, Object?> testerMap = report.toSqlMap();

    return await SqlHelper.db.insert(TABLE_NAME, testerMap);
  }

  static Future<int> updateReport(int id, TestReport report) async {
    return SqlHelper.db.update(
      TABLE_NAME,
      report.toSqlMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> loadReport({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> raws = await SqlHelper.db.query(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      orderBy: orderBy,
      columns: columns,
    );

    return raws;
  }

  static Future<TestReport?> getReport(int reportId) async {
    final list = await SqlReport.loadReport(
      where: 'id =?',
      whereArgs: [
        reportId,
      ],
    );

    if (list.isEmpty) {
      return null;
    } else {
      return TestReport.fromMap(list.first);
    }
  }

  static Future<TestReport?> getProgressReport(int userId) async {
    final list = await SqlReport.loadReport(
      where: 'userId = ? AND reportStatus = ? ',
      whereArgs: [
        userId,
        ReportStatus.running,
      ],
      orderBy: 'startAt DESC',
      limit: 1,
    );

    if (list.isEmpty) {
      return null;
    } else {
      return TestReport.fromMap(list.first);
    }
  }
}
