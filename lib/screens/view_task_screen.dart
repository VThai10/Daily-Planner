import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';

class ViewTaskScreen extends StatefulWidget {
  final int taskId;  // Nhận taskId thay vì toàn bộ dữ liệu công việc

  const ViewTaskScreen({super.key, required this.taskId});

  @override
  _ViewTaskScreenState createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  Map<String, dynamic>? task;  // Chứa dữ liệu công việc sau khi lấy từ SQLite
  bool isLoading = true;  // Biến để kiểm soát trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _loadTask();  // Gọi hàm để lấy dữ liệu từ SQLite
  }

  // Hàm để lấy công việc từ SQLite dựa trên taskId
  Future<void> _loadTask() async {
    final taskData = await DatabaseHelper.instance.getTaskById(widget.taskId);
    setState(() {
      task = taskData;
      isLoading = false;  // Đã lấy xong dữ liệu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Hiển thị vòng quay khi đang tải dữ liệu
          : task == null
              ? const Center(child: Text('Không tìm thấy công việc'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Nội dung công việc:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task!['title'] ?? 'Không có nội dung',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Ngày:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task!['date'] ?? 'Không có ngày',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Thời gian:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${task!['startTime'] ?? 'Không rõ'} - ${task!['endTime'] ?? 'Không rõ'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Địa điểm:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task!['location'] ?? 'Không có địa điểm',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Thêm trạng thái công việc
                      const Text(
                        'Trạng thái:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task!['status'] ?? 'Không có trạng thái',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Thêm ghi chú
                      const Text(
                        'Ghi chú:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task!['note'] ?? 'Không có ghi chú',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
