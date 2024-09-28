import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'view_task_screen.dart';  // Import màn hình chi tiết công việc

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dữ liệu công việc theo ngày từ SQLite
  Map<DateTime, List<Map<String, dynamic>>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();  // Gọi hàm để tải dữ liệu từ SQLite khi khởi tạo màn hình
  }

  // Hàm lấy dữ liệu từ SQLite và phân nhóm theo ngày
  Future<void> _loadTasks() async {
    final tasksFromDB = await DatabaseHelper.instance.getTasks();
    final Map<DateTime, List<Map<String, dynamic>>> taskMap = {};

    for (var task in tasksFromDB) {
      final taskDate = DateTime.parse(task['date']);  // Chuyển ngày từ chuỗi thành DateTime
      if (taskMap[taskDate] == null) {
        taskMap[taskDate] = [];
      }
      taskMap[taskDate]!.add(task);  // Thêm công việc vào danh sách theo ngày
    }

    setState(() {
      _tasks = taskMap;  // Cập nhật trạng thái với dữ liệu công việc mới
    });
  }

  // Hàm lấy công việc cho một ngày cụ thể
  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    // Sử dụng DateTime chuẩn để tránh lỗi múi giờ
    return _tasks[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch công việc'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,  // Hiển thị các công việc của từng ngày
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getTasksForDay(_selectedDay ?? DateTime.now()).length,
              itemBuilder: (context, index) {
                final task = _getTasksForDay(_selectedDay ?? DateTime.now())[index];
                return ListTile(
                  title: Text(task['title'] ?? 'Không có tiêu đề'),
                  subtitle: Text('${task['startTime']} - ${task['endTime']} tại ${task['location']}'),
                  onTap: () {
                    // Khi nhấn vào, chuyển đến ViewTaskScreen với taskId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewTaskScreen(taskId: task['id']),  // Truyền taskId vào ViewTaskScreen
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
