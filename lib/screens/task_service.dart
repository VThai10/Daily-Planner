import 'package:flutter_application_1/database_helper.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  // Hàm kiểm tra và cập nhật trạng thái công việc khi được gọi thủ công
  Future<void> checkAndUpdateTasks() async {
    DateTime now = DateTime.now();  // Thời gian hiện tại
    final List<Map<String, dynamic>> tasks = await DatabaseHelper.instance.getTasks();

    for (var task in tasks) {
      String datePart = task['date'];
      String startTimePart = task['startTime'];
      String endTimePart = task['endTime'];

      // Kiểm tra xem thời gian có hợp lệ không (định dạng HH:mm)
      if (!_isValidTimeFormat(startTimePart) || !_isValidTimeFormat(endTimePart)) {
        print('Lỗi định dạng giờ phút với công việc ID ${task['id']}');
        continue; // Bỏ qua công việc nếu định dạng giờ phút không hợp lệ
      }

      // Sử dụng hàm để chuyển đổi thời gian sang định dạng 24 giờ
      String formattedStartTime = _formatTime(startTimePart);
      String formattedEndTime = _formatTime(endTimePart);

      // Tạo chuỗi thời gian đúng định dạng 'YYYY-MM-DD HH:mm:ss'
      DateTime startTime = DateTime.parse('$datePart $formattedStartTime:00');
      DateTime endTime = DateTime.parse('$datePart $formattedEndTime:00');

      // Kiểm tra và cập nhật trạng thái công việc
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        if (task['status'] != 'Đang làm') {
          await DatabaseHelper.instance.updateTask(task['id'], {'status': 'Đang làm'});
        }
      } else if (now.isAfter(endTime)) {
        if (task['status'] != 'Kết thúc') {
          await DatabaseHelper.instance.updateTask(task['id'], {'status': 'Kết thúc'});
        }
      }
    }
  }

  // Hàm để kiểm tra định dạng thời gian (HH:mm)
  bool _isValidTimeFormat(String time) {
    final timeRegExp = RegExp(r'^\d{1,2}:\d{2}$');
    return timeRegExp.hasMatch(time);
  }

  // Hàm để chuyển đổi từ giờ 12 giờ sang định dạng 24 giờ (HH:mm)
  String _formatTime(String time) {
    final timeParts = time.split(':');
    if (timeParts.length == 2) {
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Đảm bảo định dạng giờ hợp lệ
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return time; // Nếu không phân tích được, trả về chuỗi thời gian ban đầu
  }
}
