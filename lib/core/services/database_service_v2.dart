import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/custom_question.dart';

class DatabaseService {
  static const String _dbName = 'la_previa.db';
  static const int _dbVersion = 2;

  static const int suppressThreshold = 3;

  static Database? _db;

  final List<CustomQuestion> _memoryQuestions = [];
  final Map<String, VoteCount> _memoryVotes = {};
  final Set<String> _memorySuppressed = {};

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      final factory = databaseFactoryFfiWeb;
      return factory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      return openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE votes (
        template_id   TEXT PRIMARY KEY,
        up_count      INTEGER NOT NULL DEFAULT 0,
        down_count    INTEGER NOT NULL DEFAULT 0,
        last_voted_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE suppressed (
        template_id   TEXT PRIMARY KEY,
        suppressed_at TEXT NOT NULL,
        reason        TEXT NOT NULL DEFAULT 'votes'
      )
    ''');

    await db.execute('''
      CREATE TABLE personalized (
        id            TEXT PRIMARY KEY,
        text          TEXT NOT NULL,
        drinks        INTEGER NOT NULL DEFAULT 1,
        timer_seconds INTEGER,
        league_id     TEXT,
        is_active     INTEGER NOT NULL DEFAULT 1,
        created_at    TEXT NOT NULL,
        used_count    INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE personalized ADD COLUMN league_id TEXT');
      await db.execute('ALTER TABLE personalized ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    }
  }

  // ─── VOTES ────────────────────────────────────────────────────────────────

  Future<void> vote(String templateId, VoteType type) async {
    if (kIsWeb) return;
    final db = await database;
    final rows = await db.query('votes',
        where: 'template_id = ?', whereArgs: [templateId]);

    if (rows.isEmpty) {
      await db.insert('votes', {
        'template_id':   templateId,
        'up_count':      type == VoteType.up ? 1 : 0,
        'down_count':    type == VoteType.down ? 1 : 0,
        'last_voted_at': DateTime.now().toIso8601String(),
      });
    } else {
      final current = rows.first;
      await db.update(
        'votes',
        {
          'up_count':   type == VoteType.up
              ? (current['up_count'] as int) + 1
              : current['up_count'],
          'down_count': type == VoteType.down
              ? (current['down_count'] as int) + 1
              : current['down_count'],
          'last_voted_at': DateTime.now().toIso8601String(),
        },
        where: 'template_id = ?',
        whereArgs: [templateId],
      );
    }
    await _evaluateSuppression(templateId);
  }

  Future<VoteCount?> getVoteCount(String templateId) async {
    if (kIsWeb) return null;
    final db = await database;
    final rows = await db.query('votes',
        where: 'template_id = ?', whereArgs: [templateId]);
    if (rows.isEmpty) return null;
    return VoteCount.fromRow(rows.first);
  }

  Future<Map<String, dynamic>> exportVoteSummary() async {
    if (kIsWeb) return {'totalVoted': 0, 'topRated': [], 'lowRated': []};
    final db = await database;
    final all = await db.query('votes');
    final top = [...all]
      ..sort((a, b) =>
          (b['up_count'] as int).compareTo(a['up_count'] as int));
    final low = [...all]
      ..sort((a, b) =>
          (b['down_count'] as int).compareTo(a['down_count'] as int));
    return {
      'totalVoted': all.length,
      'topRated':   top.take(10).map((r) => r['template_id']).toList(),
      'lowRated':   low.take(10).map((r) => r['template_id']).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // ─── SUPPRESSED ───────────────────────────────────────────────────────────

  Future<void> _evaluateSuppression(String templateId) async {
    if (kIsWeb) return;
    final db = await database;
    final rows = await db.query('votes',
        where: 'template_id = ?', whereArgs: [templateId]);
    if (rows.isEmpty) return;
    if ((rows.first['down_count'] as int) >= suppressThreshold) {
      await suppress(templateId, reason: 'votes');
    }
  }

  Future<void> suppress(String templateId,
      {String reason = 'manual'}) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'suppressed',
      {
        'template_id':   templateId,
        'suppressed_at': DateTime.now().toIso8601String(),
        'reason':        reason,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> restore(String templateId) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('suppressed',
        where: 'template_id = ?', whereArgs: [templateId]);
  }

  Future<Set<String>> getSuppressedIds() async {
    if (kIsWeb) return _memorySuppressed;
    final db = await database;
    final rows = await db.query('suppressed', columns: ['template_id']);
    return rows.map((r) => r['template_id'] as String).toSet();
  }

  Future<bool> isSuppressed(String templateId) async {
    final ids = await getSuppressedIds();
    return ids.contains(templateId);
  }

  // ─── PERSONALIZED ─────────────────────────────────────────────────────────

  Future<void> savePersonalizedQuestion(CustomQuestion question) async {
    if (kIsWeb) {
      _memoryQuestions.add(question);
      return;
    }
    final db = await database;
    await db.insert(
      'personalized',
      {
        'id':            question.id,
        'text':          question.text,
        'drinks':        question.drinks,
        'timer_seconds': question.timerSeconds,
        'league_id':     question.leagueId,
        'is_active':     question.isActive ? 1 : 0,
        'created_at':    DateTime.now().toIso8601String(),
        'used_count':    0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> savePersonalizedQuestions(List<CustomQuestion> questions) async {
    if (kIsWeb) {
      for (var q in questions) {
        _memoryQuestions.add(q);
      }
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      for (final q in questions) {
        await txn.insert(
          'personalized',
          {
            'id':            q.id,
            'text':          q.text,
            'drinks':        q.drinks,
            'timer_seconds': q.timerSeconds,
            'league_id':     q.leagueId,
            'is_active':     q.isActive ? 1 : 0,
            'created_at':    DateTime.now().toIso8601String(),
            'used_count':    0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<CustomQuestion>> getPersonalizedQuestions(String leagueId) async {
    if (kIsWeb) return _memoryQuestions.where((q) => q.leagueId == leagueId).toList();
    final db = await database;
    final rows = await db.query('personalized',
        where: 'league_id = ?',
        whereArgs: [leagueId],
        orderBy: 'used_count ASC, created_at DESC');
    return rows.map(CustomQuestion.fromRow).toList();
  }

  Future<List<CustomQuestion>> getActivePersonalizedQuestions(String leagueId) async {
    if (kIsWeb) return _memoryQuestions.where((q) => q.leagueId == leagueId && q.isActive).toList();
    final db = await database;
    final rows = await db.query('personalized',
        where: 'league_id = ? AND is_active = 1',
        whereArgs: [leagueId],
        orderBy: 'used_count ASC, created_at DESC');
    return rows.map(CustomQuestion.fromRow).toList();
  }

  Future<void> updatePersonalizedQuestion(CustomQuestion question) async {
    if (kIsWeb) {
      final idx = _memoryQuestions.indexWhere((q) => q.id == question.id);
      if (idx != -1) _memoryQuestions[idx] = question;
      return;
    }
    final db = await database;
    await db.update(
      'personalized',
      {
        'text':          question.text,
        'drinks':        question.drinks,
        'timer_seconds': question.timerSeconds,
        'league_id':     question.leagueId,
        'is_active':     question.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<void> deletePersonalizedQuestion(String id) async {
    if (kIsWeb) {
      _memoryQuestions.removeWhere((q) => q.id == id);
      return;
    }
    final db = await database;
    await db.delete('personalized', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markPersonalizedAsUsed(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.rawUpdate(
        'UPDATE personalized SET used_count = used_count + 1 WHERE id = ?',
        [id]);
  }

  Future<void> togglePersonalizedQuestionStatus(String id, bool isActive) async {
    if (kIsWeb) {
      final idx = _memoryQuestions.indexWhere((q) => q.id == id);
      if (idx != -1) {
        final old = _memoryQuestions[idx];
        _memoryQuestions[idx] = CustomQuestion(
          id: old.id,
          text: old.text,
          drinks: old.drinks,
          timerSeconds: old.timerSeconds,
          leagueId: old.leagueId,
          isActive: isActive,
        );
      }
      return;
    }
    final db = await database;
    await db.update(
      'personalized',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasPersonalizedQuestions() async {
    if (kIsWeb) return _memoryQuestions.isNotEmpty;
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM personalized'));
    return (count ?? 0) > 0;
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    await db.close();
    _db = null;
  }
}

// ---------------------------------------------------------------------------
// MODELOS
// ---------------------------------------------------------------------------

enum VoteType { up, down }

class VoteCount {
  final String templateId;
  final int upCount;
  final int downCount;

  const VoteCount({
    required this.templateId,
    required this.upCount,
    required this.downCount,
  });

  factory VoteCount.fromRow(Map<String, dynamic> row) => VoteCount(
        templateId: row['template_id'] as String,
        upCount:    row['up_count']    as int,
        downCount:  row['down_count']  as int,
      );

  double get rating {
    final total = upCount + downCount;
    if (total == 0) return 0.5;
    return upCount / total;
  }
}