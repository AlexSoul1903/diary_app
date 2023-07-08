import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'Diary.dart';

class DbManager {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (_database == null) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'diary.db');

      return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE diario(id INTEGER PRIMARY KEY, title TEXT, date TEXT, description TEXT, photo TEXT, audio TEXT)');
        },
      );
    }

    return _database!;
  }

  static Future<List<DiaryEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diario');

    return List.generate(maps.length, (i) {
      return DiaryEntry(
        id: maps[i]['id'],
        title: maps[i]['title'],
        date: maps[i]['date'],
        description: maps[i]['description'],
        photo: maps[i]['photo'],
        audio: maps[i]['audio'],
      );
    });
  }

  static Future<List<DiaryEntry>> getEntriesByTitle(String tilte) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diario',
      where: 'title LIKE ?',
      whereArgs: ['%$tilte%'],
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry(
        id: maps[i]['id'],
        title: maps[i]['title'],
        date: maps[i]['date'],
        description: maps[i]['description'],
        photo: maps[i]['photo'],
        audio: maps[i]['audio'],
      );
    });
  }

  static Future<List<DiaryEntry>> getEntriesByDate(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diario',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry(
        id: maps[i]['id'],
        title: maps[i]['title'],
        date: maps[i]['date'],
        description: maps[i]['description'],
        photo: maps[i]['photo'],
        audio: maps[i]['audio'],
      );
    });
  }

  static Future<void> addEntry(DiaryEntry entry) async {
    final db = await database;

    await db.insert(
      'diario',
      {
        'title': entry.title,
        'date': entry.date,
        'description': entry.description,
        'photo': entry.photo,
        'audio': entry.audio,
      },
    );
  }

  static Future<void> deleteAllEntries() async {
    final db = await database;

    // Obtener todas las entradas existentes
    final entries = await db.query('diario');

    // Eliminar los archivos de audio asociados a cada entrada
    for (final entry in entries) {
      final audioPath = entry['audio'] as String?;
      if (audioPath != null) {
        final audioFile = File(audioPath);
        if (audioFile.existsSync()) {
          await audioFile.delete();
        }
      }
    }

    for (final entry in entries) {
      final imagePath = entry['photo'] as String?;
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          await imageFile.delete();
        }
      }
    }

    await db.delete('diario');
  }

  static Future<int?> deleteEntry(int? id) async {
    final db = await database;
    final entryToDelete =
        await db.query('diario', where: "id = ?", whereArgs: [id]);

    // Eliminar los archivos de audio asociados a la entrada
    for (final entry in entryToDelete) {
      final audioPath = entry['audio'] as String?;
      if (audioPath != null) {
        final audioFile = File(audioPath);
        if (audioFile.existsSync()) {
          await audioFile.delete();
        }
      }
    }

    // Eliminar los archivos de imagen asociados a la entrada
    for (final entry in entryToDelete) {
      final imagePath = entry['photo'] as String?;
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          await imageFile.delete();
        }
      }
    }

    return await db.delete('diario', where: "id = ?", whereArgs: [id]);
  }
}
