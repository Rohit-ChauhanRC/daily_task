import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'task_controller.dart';

void main() {
  runApp(GetMaterialApp(
    title: "Book List",
    home: TaskPage(),
  ));
}

class TaskPage extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.calendar_today),
          //   onPressed: () async {
          //     final selectedDate = await showDatePicker(
          //       context: context,
          //       initialDate: controller.selectedDate.value,
          //       firstDate: DateTime(2000),
          //       lastDate: DateTime(2100),
          //     );
          //     if (selectedDate != null) {
          //       controller.filterTasksByDate(selectedDate);
          //     }
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // Display selected date
          // Obx(() {
          //   return Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text(
          //       'Tasks for ${controller.formattedSelectedDate}',
          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //     ),
          //   );
          // }),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.tasks.length,
                itemBuilder: (context, index) {
                  final task = controller.tasks[index];
                  return ListTile(
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: task['completed'] == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                        'Start Date: ${controller.formatDateTime(task['date'])}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task['completed'] == 1,
                          onChanged: (value) {
                            controller.updateTask(
                              task['id'],
                              task['title'],
                              task['date'],
                              value! ? 1 : 0,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditTaskDialog(context, task);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(context, task['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text('Pick Date'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  controller.addTask(
                      titleController.text, selectedDate.toString());
                  Get.back();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    DateTime selectedDate = DateTime.parse(task['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                child: Text('Pick Date'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                controller.updateTask(task['id'], titleController.text,
                    selectedDate.toString(), task['completed']);
                Get.back();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                controller.deleteTask(id);
                Get.back();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
