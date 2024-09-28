import 'package:flutter/material.dart';
import 'package:flutter_application_1/database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;  // Nhận dữ liệu task để chỉnh sửa nếu có

  const AddTaskScreen({super.key, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();  // Khóa FormState để xác thực
  final _taskController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isSaving = false; // Trạng thái lưu công việc

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Nếu là chỉnh sửa công việc, load dữ liệu cũ
      _taskController.text = widget.task!['title'] ?? '';
      _locationController.text = widget.task!['location'] ?? '';
      _notesController.text = widget.task!['note'] ?? '';
      _selectedDate = DateTime.parse(widget.task!['date']);
      _startTime = TimeOfDay(
        hour: int.parse(widget.task!['startTime'].split(':')[0]),
        minute: int.parse(widget.task!['startTime'].split(':')[1]),
      );
      _endTime = TimeOfDay(
        hour: int.parse(widget.task!['endTime'].split(':')[0]),
        minute: int.parse(widget.task!['endTime'].split(':')[1]),
      );
    }
  }

  // Hàm lưu công việc
  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;  // Tránh nhấn nút lưu nhiều lần
      });

      Map<String, dynamic> task = {
        'title': _taskController.text,
        'date': _selectedDate?.toIso8601String() ?? '',
        'startTime': '${_startTime?.hour}:${_startTime?.minute}',
        'endTime': '${_endTime?.hour}:${_endTime?.minute}',
        'location': _locationController.text,
        'note': _notesController.text,
        'status': 'Chờ duyệt',  // Mặc định trạng thái là "Chờ duyệt"
      };

      if (widget.task == null) {
        // Thêm mới
        await DatabaseHelper.instance.addTask(task);
      } else {
        // Cập nhật
        await DatabaseHelper.instance.updateTask(widget.task!['id'], task);
      }

      Navigator.pop(context, task);  // Quay lại màn hình danh sách công việc sau khi lưu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm Công việc mới' : 'Chỉnh sửa Công việc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Ngày: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Chọn ngày',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung công việc',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung công việc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _startTime != null
                        ? 'Bắt đầu: ${_startTime!.format(context)}'
                        : 'Chọn giờ bắt đầu',
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectStartTime(context),
                  ),
                  Text(
                    _endTime != null
                        ? 'Kết thúc: ${_endTime!.format(context)}'
                        : 'Chọn giờ kết thúc',
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectEndTime(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa điểm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveTask,  // Tránh nhấn nhiều lần
                child: _isSaving ? const CircularProgressIndicator() : const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }
}
