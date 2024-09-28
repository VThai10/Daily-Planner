import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';
import 'in_progress_task_screen.dart';  // Import trang "Đang làm"

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  _ApprovalScreenState createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  List<Map<String, dynamic>> pendingTasks = [];
  String? _selectedStatus = 'Chờ duyệt';  // Mặc định lọc theo trạng thái "Chờ duyệt"

  final List<String> _statuses = [
    'Chờ duyệt', 
    'Đã duyệt', 
    'Bị hủy', 
    'Tất cả'
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingTasks();  // Lấy các công việc theo trạng thái từ database
  }

  // Lấy các công việc từ SQLite với bộ lọc trạng thái
  Future<void> _loadPendingTasks() async {
    final tasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      pendingTasks = tasks.where((task) {
        if (_selectedStatus != 'Tất cả' && task['status'] != _selectedStatus) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  // Hàm xử lý duyệt công việc
  Future<void> _approveTask(int id) async {
    await DatabaseHelper.instance.updateTask(id, {'status': 'Đã duyệt'});
    _loadPendingTasks();  // Tải lại danh sách sau khi duyệt
  }

  // Hàm xử lý từ chối công việc
  Future<void> _rejectTask(int id) async {
    await DatabaseHelper.instance.updateTask(id, {'status': 'Bị hủy'});
    _loadPendingTasks();  // Tải lại danh sách sau khi từ chối
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm duyệt công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InProgressTaskScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc theo trạng thái
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
                  _loadPendingTasks();  // Tải lại danh sách khi thay đổi bộ lọc
                });
              },
              decoration: const InputDecoration(
                labelText: 'Lọc theo trạng thái',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: pendingTasks.isEmpty
                ? const Center(child: Text('Không có công việc nào'))
                : ListView.builder(
                    itemCount: pendingTasks.length,
                    itemBuilder: (context, index) {
                      final task = pendingTasks[index];

                      return ListTile(
                        title: Text(task['title'] ?? 'Không có tiêu đề'),
                        subtitle: Text('${task['startTime']} - ${task['endTime']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveTask(task['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () => _rejectTask(task['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
