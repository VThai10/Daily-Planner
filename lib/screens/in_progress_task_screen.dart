import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';

class InProgressTaskScreen extends StatefulWidget {
  const InProgressTaskScreen({super.key});

  @override
  _InProgressTaskScreenState createState() => _InProgressTaskScreenState();
}

class _InProgressTaskScreenState extends State<InProgressTaskScreen> {
  List<Map<String, dynamic>> inProgressTasks = [];
  final List<String> _statuses = ['Đang làm', 'Bị dừng', 'Kết thúc'];

  @override
  void initState() {
    super.initState();
    _loadInProgressTasks();  // Lấy dữ liệu công việc đang làm
  }

  // Hàm lấy công việc từ SQLite có trạng thái "Đang làm" hoặc "Đã duyệt"
  Future<void> _loadInProgressTasks() async {
    final tasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      inProgressTasks = tasks
          .where((task) => task['status'] == 'Đang làm' || task['status'] == 'Đã duyệt')
          .toList();
    });
  }

  // Hàm cập nhật trạng thái công việc thủ công
  Future<void> _updateTaskStatus(int id, String newStatus) async {
    await DatabaseHelper.instance.updateTask(id, {'status': newStatus});
    _loadInProgressTasks();  // Cập nhật lại danh sách sau khi thay đổi trạng thái
  }

  // Hiển thị hộp thoại xác nhận khi thay đổi trạng thái
  Future<void> _confirmUpdateStatus(int id, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn thay đổi trạng thái thành $newStatus không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),  // Không thay đổi
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),  // Xác nhận thay đổi
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateTaskStatus(id, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc đang thực hiện'),
      ),
      body: inProgressTasks.isEmpty
          ? const Center(child: Text('Không có công việc đang làm'))
          : ListView.builder(
              itemCount: inProgressTasks.length,
              itemBuilder: (context, index) {
                final task = inProgressTasks[index];
                
                // Xử lý giá trị mặc định cho DropdownButton nếu trạng thái hiện tại không nằm trong _statuses
                final currentStatus = _statuses.contains(task['status'])
                    ? task['status']
                    : 'Đang làm';  // Mặc định là "Đang làm" nếu trạng thái không hợp lệ

                return ListTile(
                  title: Text(task['title'] ?? 'Không có tiêu đề'),
                  subtitle: Text(
                    '${task['startTime']} - ${task['endTime']} tại ${task['location']}',
                  ),
                  trailing: DropdownButton<String>(
                    value: currentStatus,  // Giá trị hiện tại của trạng thái
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _confirmUpdateStatus(task['id'], newValue);  // Cập nhật trạng thái khi chọn
                      }
                    },
                    items: _statuses.map<DropdownMenuItem<String>>((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
