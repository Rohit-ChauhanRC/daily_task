import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskController extends GetxController {
  var tasks = <Map<String, dynamic>>[].obs;
  late Database database;
  var filteredTasks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
  }

  String formatDateTime(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy hh:mm a').format(dateTime);
    return formattedDate;
  }

  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, completed INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('ALTER TABLE tasks ADD COLUMN date TEXT');
        }
      },
      version: 2, // Increment the version number
    );
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final List<Map<String, dynamic>> data = await database.query('tasks');
    tasks.assignAll(data);
    filterTasksByDate(DateTime.now());
  }

  Future<void> addTask(String title, String date) async {
    await database.insert(
      'tasks',
      {'title': title, 'date': date, 'completed': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    fetchTasks();
  }

  Future<void> updateTask(int id, bool completed) async {
    await database.update(
      'tasks',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchTasks();
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = join(await getDatabasesPath(), 'tasks.db');
    await deleteDatabase(dbPath);
  }

  void filterTasksByDate(DateTime date) {
    // Format the input date to match the task's formatted date
    final formattedDate = formatDateTime(date.toString());

    // Filter tasks by comparing formatted dates
    filteredTasks.assignAll(
      tasks.where((task) {
        final taskFormattedDate = formatDateTime(task['date']);
        return taskFormattedDate == formattedDate;
      }).toList(),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
