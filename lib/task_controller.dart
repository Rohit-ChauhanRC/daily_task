import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class TaskController extends GetxController {
  var tasks = <Map<String, dynamic>>[].obs;
  var filteredTasks = <Map<String, dynamic>>[].obs;
  var selectedDate = DateTime.now().obs;
  late Database database;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, completed INTEGER)',
        );
      },
      version: 1,
    );
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final List<Map<String, dynamic>> data = await database.query('tasks');
    tasks.assignAll(data);
    filterTasksByDate(selectedDate.value);
  }

  Future<void> addTask(String title, String date) async {
    await database.insert(
      'tasks',
      {'title': title, 'date': date, 'completed': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    fetchTasks();
  }

  Future<void> updateTask(
      int id, String title, String date, int completed) async {
    await database.update(
      'tasks',
      {'title': title, 'date': date, 'completed': completed},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchTasks();
  }

  void filterTasksByDate(DateTime date) {
    selectedDate.value = date;
    final formattedDate = formatDateTime(date.toString());
    filteredTasks.assignAll(
      tasks.where((task) {
        final taskFormattedDate = formatDateTime(task['date']);
        return taskFormattedDate == formattedDate;
      }).toList(),
    );
  }

  String formatDateTime(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String get formattedSelectedDate {
    return DateFormat('dd MMM yyyy').format(selectedDate.value);
  }
}
