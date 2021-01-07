import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ticket_model.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  final String ticketList = 'ticket_list';

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "Novotix.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  String _path;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    _path = join(documentsDirectory.path + "/novotixdb", _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(_path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $ticketList (
                ColumnId INTEGER PRIMARY KEY,
                ${TicketValues.evenDataId} INTEGER,
                ${TicketValues.bookingId} INTEGER,
                ${TicketValues.eventId} INTEGER,
                ${TicketValues.barcodeId} TEXT,
                ${TicketValues.attendeeName} TEXT,
                ${TicketValues.ticketType} TEXT,
                ${TicketValues.validFromDateTime} TEXT,
                ${TicketValues.validToDateTime} TEXT,
                ${TicketValues.ticketValidated} INTEGER,
                ${TicketValues.ticketValidatedDateTime} TEXT,
                ${TicketValues.TicketValidationStatus} INTEGER,
                ${TicketValues.status} TEXT
              )
              ''');
  }

  Future<int> insert(TicketModel ticketModel) async {
    Database db = await database;
    int id = await db.insert(ticketList, ticketModel.toMap());
    return id;
  }

  Future<TicketModel> queryTicketList(String barcode) async {
    Database db = await database;
    List<Map> maps = await db.query(
      ticketList,
      where: '${TicketValues.barcodeId}=?',
      whereArgs: [barcode],
    );
    if (maps.length > 0) {
      return TicketModel.mapToTicket(maps.first);
    }
    return null;
  }

  Future<List<TicketModel>> getAllTicketsFromDatabase() async {
    Database db = await database;
    List<Map> maps = await db.query(ticketList);
    if (maps != null || maps.length > 0) {
      return maps.map((e) => TicketModel.mapToTicket(e)).toList();
    }
    return [];
  }

  Future<bool> queryTicketListId(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(
      ticketList,
      columns: [TicketValues.evenDataId],
      where: '${TicketValues.evenDataId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

  Future<void> deleteTable() async {
    Database db = await database;
    await db.delete(ticketList);
  }

  // Future<int> updateValidationStatusInDatabase(
  //     String barcode, String status) async {
  //   Database db = await database;
  //   int updatedField = await db.rawUpdate(
  //     '''
  //   UPDATE $ticketList
  //   SET  ${TicketValues.status} = $status
  //   WHERE ${TicketValues.barcodeId} = ?
  //   ''',
  //     [barcode],
  //   );
  //
  //   return updatedField;
  // }

  Future<int> updateValidTicketInDatabase(
      String field, String searchVal, String newVal) async {
    Database db = await database;
    int updatedField = await db.rawUpdate(
      '''
    UPDATE $ticketList
    SET  $field = ?
    WHERE ${TicketValues.barcodeId} = ?
    ''',
      [newVal, searchVal],
    );

    return updatedField;
  }

  Future<int> syncLocalDatabase(
      int searchVal, int newVal1, int newVal2, String newVal3) async {
    Database db = await database;
    int updatedField = await db.rawUpdate(
      '''
    UPDATE $ticketList
    SET  ${TicketValues.ticketValidated} = ? , ${TicketValues.ticketValidationStatus} = ? , ${TicketValues.ticketValidatedDateTime} = ?
    WHERE ${TicketValues.evenDataId} = ?
    ''',
      [newVal1, newVal2, newVal3, searchVal],
    );

    return updatedField;
  }
}
