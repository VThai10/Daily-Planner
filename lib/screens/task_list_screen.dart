import 'package:flutter/material.dart';
import 'add_task_screen.dart';  // Import trang thêm công việc
import 'view_task_screen.dart';  // Import trang xem chi tiết công việc
import 'package:flutter_application_1/database_helper.dart';  // Import DatabaseHelper

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];  // Lưu danh sách công việc từ SQLite
  String? _selectedStatus = 'Tất cả';  // Trạng thái được chọn để lọc công việc

  final List<String> _statuses = [
    'Tất cả',
    'Chờ duyệt',
    'Đã duyệt',
    'Bị hủy',
    'Đang làm',
    'Bị dừng',
    'Kết thúc'  // Cập nhật trạng thái "Kết thúc" thay cho "Chưa hoàn thành" và "Đã hoàn thành"
  ]; // Bộ lọc trạng thái

  @override
  void initState() {
    super.initState();
    _loadTasks();  // Lấy dữ liệu khi khởi động màn hình
  }

  // Hàm lấy dữ liệu từ SQLite và cập nhật vào danh sách
  Future<void> _loadTasks() async {
    final taskList = await DatabaseHelper.instance.getTasks();  // Lấy công việc từ database
    setState(() {
      tasks = taskList;  // Cập nhật danh sách công việc
    });
  }

  // Lọc công việc theo trạng thái
  List<Map<String, dynamic>> _filterTasks() {
    if (_selectedStatus == 'Tất cả') {
      return tasks;
    } else {
      return tasks.where((task) => task['status'] == _selectedStatus).toList();
    }
  }

  // Hàm xóa công việc với xác nhận
  Future<void> _deleteTask(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmDelete == true) {
      await DatabaseHelper.instance.deleteTask(id);  // Xóa công việc
      _loadTasks();  // Tải lại danh sách sau khi xóa
    }
  }

  // Lấy màu dựa trên trạng thái công việc
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Đã duyệt':
        return Colors.lightGreen;
      case 'Bị hủy':
        return Colors.red;
      case 'Đang làm':
        return Colors.blue;
      case 'Bị dừng':
        return Colors.grey;
      case 'Kết thúc':  // Sử dụng màu cho trạng thái "Kết thúc"
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  // Hàm hiển thị hộp thoại yêu cầu cập nhật task
  Future<void> _restartTask(Map<String, dynamic> task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: task),
      ),
    );
    if (updatedTask != null) {
      updatedTask['status'] = 'Chờ duyệt';  // Đặt lại trạng thái thành "Chờ duyệt"
      await DatabaseHelper.instance.updateTask(task['id'], updatedTask);  // Cập nhật lại công việc
      _loadTasks();  // Tải lại danh sách công việc
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterTasks();  // Lọc công việc theo trạng thái

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),  // Tiêu đề màn hình
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Cài đặt') {
                // Điều hướng đến trang "Cài đặt"
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'Sắp xếp công việc') {
                // Điều hướng đến trang "Sắp xếp công việc"
                Navigator.pushNamed(context, '/sort_tasks');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Cài đặt',
                  child: Text('Cài đặt'),
                ),
                const PopupMenuItem<String>(
                  value: 'Sắp xếp công việc',
                  child: Text('Sắp xếp công việc'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc trạng thái
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Lọc theo trạng thái',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text('Không có công việc nào'))  // Hiển thị nếu không có task nào
                : ListView.builder(
                    itemCount: filteredTasks.length,  // Số lượng công việc
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];  // Lấy từng công việc
                      final statusColor = _getStatusColor(task['status']);  // Lấy màu tương ứng với trạng thái

                      return ListTile(
                        title: Text(
                          task['title'] ?? 'Không có tiêu đề',
                          style: TextStyle(color: statusColor),  // Cập nhật màu trạng thái
                        ),
                        subtitle: Text('${task['startTime']} - ${task['endTime']}'),
                        onTap: () {
                          // Khi nhấn vào sẽ chuyển đến trang ViewTaskScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewTaskScreen(taskId: task['id']),  // Truyền taskId sang trang chi tiết công việc
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (['Bị hủy', 'Bị dừng', 'Kết thúc']
                                .contains(task['status']))
                              TextButton(
                                onPressed: () => _restartTask(task),  // Tái khởi động công việc
                                child: const Text('Tái khởi động'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),  // Nút chỉnh sửa
                              onPressed: () async {
                                // Khi nhấn vào sẽ chuyển đến AddTaskScreen để chỉnh sửa công việc
                                final editedTask = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskScreen(task: task),  // Truyền dữ liệu công việc sang trang chỉnh sửa
                                  ),
                                );
                                if (editedTask != null) {
                                  _loadTasks();  // Tải lại danh sách nếu công việc đã được chỉnh sửa
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),  // Nút xóa công việc
                              onPressed: () => _deleteTask(task['id']),  // Gọi hàm xóa công việc với xác nhận
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Chuyển đến trang AddTaskScreen để thêm công việc mới
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),  // Chuyển đến trang thêm công việc
            ),
          );
          if (newTask != null) {
            _loadTasks();  // Tải lại danh sách công việc nếu công việc mới được thêm
          }
        },
        child: const Icon(Icons.add),  // Nút thêm công việc
      ),
    );
  }
}
