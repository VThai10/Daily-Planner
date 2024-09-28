import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/task_list_screen.dart'; // Import màn hình danh sách công việc
import 'screens/calendar_view_screen.dart'; // Import màn hình lịch
import 'screens/approval_screen.dart'; // Import màn hình kiểm duyệt
import 'screens/task_service.dart'; // Import TaskService để chạy background service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null); // Khởi tạo định dạng ngày tháng tiếng Việt
  
  // Khởi động dịch vụ kiểm tra công việc
  
  
  runApp(const DailyPlannerApp());
}

class DailyPlannerApp extends StatelessWidget {
  const DailyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(), // Chuyển tới MainScreen với Bottom Navigation Bar
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Chỉ mục hiện tại của màn hình

  // Danh sách các màn hình chính
  final List<Widget> _screens = [
    const TaskListScreen(), // Màn hình danh sách công việc
    const CalendarViewScreen(), // Màn hình lịch
    const ApprovalScreen(), // Màn hình kiểm duyệt công việc
  ];

  // Hàm thay đổi màn hình khi người dùng nhấn vào icon
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Hiển thị màn hình dựa trên chỉ mục hiện tại
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Chỉ mục hiện tại
        onTap: _onItemTapped, // Gọi hàm khi người dùng nhấn vào icon
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Công việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Kiểm duyệt', // Thêm icon cho màn hình kiểm duyệt
          ),
        ],
      ),
    );
  }
}
