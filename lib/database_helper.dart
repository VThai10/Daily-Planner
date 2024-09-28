import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        location TEXT,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'Chờ duyệt'
      )
    ''');
  }

  Future<int> addTask(Map<String, dynamic> task) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      return await txn.insert('tasks', task);
    });
  }

  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      return await txn.update(
        'tasks',
        task,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Lấy danh sách công việc
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await instance.database;
    return await db.query('tasks');
  }

  // Lấy danh sách công việc theo trạng thái
  Future<List<Map<String, dynamic>>> getTasksByStatus(String status) async {
    final db = await instance.database;
    return await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  // Xóa công việc
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await instance.database;
  
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  
    if (result.isNotEmpty) {
      return result.first;  // Trả về công việc đầu tiên nếu tìm thấy
    } else {
      return null;  // Trả về null nếu không tìm thấy công việc
    }
  }

  // Phương thức tự động cập nhật trạng thái công việc
  Future<void> updateTaskStatuses(DateTime currentTime) async {
    final db = await instance.database;
    
    // Lấy danh sách các công việc cần cập nhật
    final tasks = await db.query('tasks');
    
    for (var task in tasks) {
      final startTime = DateTime.parse('${task['date']}T${task['startTime']}');
      final endTime = DateTime.parse('${task['date']}T${task['endTime']}');

      if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
  // Nếu công việc đã bắt đầu nhưng chưa kết thúc, chuyển trạng thái thành 'Đang làm'
  if (task['status'] != 'Đang làm') {
    await updateTask(task['id'] as int, {'status': 'Đang làm'});
  }
} else if (currentTime.isAfter(endTime)) {
  // Nếu đã vượt qua giờ kết thúc, chuyển trạng thái thành 'Kết thúc'
  if (task['status'] != 'Kết thúc') {
    await updateTask(task['id'] as int, {'status': 'Kết thúc'});
  }
}

    }
  }
}
