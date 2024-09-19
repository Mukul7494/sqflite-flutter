import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  //here a private constructor is used to prevent instantiation of the class
  DBHelper._();

//this is the only instance of the class to statically use the same database connection
  static final DBHelper instance = DBHelper._();
  static const String idColumn = 'id';
  static const String tableName = 'notes';
  static const String titleColumn = 'title';
  static const String descColumn = 'description';

  Database? _mydb;

//here i am getting the db
  Future<Database> getDb() async {
    if (_mydb != null) {
      return _mydb!;
    } else {
      _mydb = await openDb();
      return _mydb!;
    }
  }

  //here  i am opening the db
  Future<Database> openDb() async {
    //here i am getting the path of the application folder
    final Directory appDir = await getApplicationDocumentsDirectory();

    //here i am getting the path of the database
    final String dbPath = join(appDir.path, 'notes.db');

    //here i am creating the database and returning it
    //the version here is to be used when you want to upgrade the database means when you want to change the schema of the database
    //onCreate is a callback function that is called when the database is created
    return openDatabase(dbPath, version: 1, onCreate: (db, version) {
      //here we are creating the table using sql
      db.execute(
          "CREATE TABLE $tableName($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $titleColumn TEXT, $descColumn TEXT)");
    });
  }

  //this function is used for adding a note to the database
  Future<bool> addNote(String title, String desc) async {
    final Database db = await getDb();

    //here this function will return rows affected by the query
    int rowsEffected =
        await db.insert(tableName, {titleColumn: title, descColumn: desc});

    //this will check if any row effected or not
    return rowsEffected > 0;
  }

  //this function is used for getting all the note from the database
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final Database db = await getDb();

    //here this function will return rows affected by the query
    //we can add column and where condtion like sql

    //this is same as
    //SELECT * FROM table;
    List<Map<String, dynamic>> notes = await db.query(tableName);
    print(notes.toString());

    //this will give all the notes
    return notes;
  }

  //this function is used for updating a note in the database

  Future<bool> updateNote(String title, String desc, int id) async {
    final Database db = await getDb();
    int rowsEffected = await db.update(
        tableName, {titleColumn: title, descColumn: desc},
        where: '$idColumn = ?', whereArgs: [id]);
    return rowsEffected > 0;
  }

  //this function is used for deleting a note from the database

  Future<bool> deleteNote(int id) async {
    final Database db = await getDb();
    int rowsEffected =
        await db.delete(tableName, where: '$idColumn = ?', whereArgs: [id]);
    return rowsEffected > 0;
  }
}
