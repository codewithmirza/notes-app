import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop and recreate tables with correct schema
      await db.execute('DROP TABLE IF EXISTS notes');
      await db.execute('DROP TABLE IF EXISTS note_blocks');
      await db.execute('DROP TABLE IF EXISTS database_columns');
      await db.execute('DROP TABLE IF EXISTS database_rows');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        color TEXT,
        tags TEXT,
        isPinned INTEGER NOT NULL DEFAULT 0,
        parentId TEXT,
        "order" INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'page'
      )
    ''');

    // Create note_blocks table for Notion-like blocks
    await db.execute('''
      CREATE TABLE note_blocks(
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        parentId TEXT,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');

    // Create database_columns table for Notion-like databases
    await db.execute('''
      CREATE TABLE database_columns(
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        properties TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');

    // Create database_rows table for Notion-like database rows
    await db.execute('''
      CREATE TABLE database_rows(
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        cells TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notes_parentId ON notes(parentId)');
    await db.execute('CREATE INDEX idx_notes_type ON notes(type)');
    await db.execute('CREATE INDEX idx_notes_isPinned ON notes(isPinned)');
    await db.execute('CREATE INDEX idx_note_blocks_noteId ON note_blocks(noteId)');
    await db.execute('CREATE INDEX idx_database_columns_noteId ON database_columns(noteId)');
    await db.execute('CREATE INDEX idx_database_rows_noteId ON database_rows(noteId)');
  }

  // Note CRUD operations
  Future<String> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', note.toJson());
    return note.id;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, order_index ASC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }

  Future<List<Note>> getNotesByParent(String? parentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'parentId = ?',
      whereArgs: [parentId],
      orderBy: 'isPinned DESC, order_index ASC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, order_index ASC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }

  Future<List<Note>> getNotesByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'isPinned DESC, order_index ASC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(String id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Note blocks operations
  Future<String> insertNoteBlock(NoteBlock block, String noteId) async {
    final db = await database;
    final blockData = block.toJson();
    blockData['noteId'] = noteId;
    await db.insert('note_blocks', blockData);
    return block.id;
  }

  Future<List<NoteBlock>> getNoteBlocks(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'note_blocks',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'order_index ASC',
    );
    return List.generate(maps.length, (i) => NoteBlock.fromJson(maps[i]));
  }

  Future<int> updateNoteBlock(NoteBlock block) async {
    final db = await database;
    return await db.update(
      'note_blocks',
      block.toJson(),
      where: 'id = ?',
      whereArgs: [block.id],
    );
  }

  Future<int> deleteNoteBlock(String id) async {
    final db = await database;
    return await db.delete(
      'note_blocks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database columns operations
  Future<String> insertDatabaseColumn(DatabaseColumn column, String noteId) async {
    final db = await database;
    final columnData = column.toJson();
    columnData['noteId'] = noteId;
    await db.insert('database_columns', columnData);
    return column.id;
  }

  Future<List<DatabaseColumn>> getDatabaseColumns(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'database_columns',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'order_index ASC',
    );
    return List.generate(maps.length, (i) => DatabaseColumn.fromJson(maps[i]));
  }

  // Database rows operations
  Future<String> insertDatabaseRow(DatabaseRow row, String noteId) async {
    final db = await database;
    final rowData = row.toJson();
    rowData['noteId'] = noteId;
    await db.insert('database_rows', rowData);
    return row.id;
  }

  Future<List<DatabaseRow>> getDatabaseRows(String noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'database_rows',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => DatabaseRow.fromJson(maps[i]));
  }

  Future<int> updateDatabaseRow(DatabaseRow row) async {
    final db = await database;
    return await db.update(
      'database_rows',
      row.toJson(),
      where: 'id = ?',
      whereArgs: [row.id],
    );
  }

  Future<int> deleteDatabaseRow(String id) async {
    final db = await database;
    return await db.delete(
      'database_rows',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Utility methods
  Future<List<String>> getAllTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      columns: ['tags'],
      where: 'tags IS NOT NULL AND tags != ""',
    );
    
    Set<String> allTags = {};
    for (var map in maps) {
      final tagsJson = map['tags'] as String?;
      if (tagsJson != null && tagsJson.isNotEmpty) {
        final tags = tagsJson.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty);
        allTags.addAll(tags);
      }
    }
    
    return allTags.toList()..sort();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
