import 'package:flutter/material.dart';
import 'task_list_screen.dart'; // Import màn hình TaskListScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Hàm xử lý đăng nhập (giả định đăng nhập thành công)
  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Giả sử kiểm tra thông tin đăng nhập thành công
    if (email.isNotEmpty && password.isNotEmpty) {
      // Điều hướng sang màn hình danh sách công việc
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskListScreen()),
      );
    } else {
      // Nếu thông tin đăng nhập không hợp lệ, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thông tin hợp lệ!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.purple, backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),  // Gọi hàm _login khi nhấn nút Đăng nhập
              child: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Đăng nhập bằng tài khoản sinh viên',
                style: TextStyle(
                  color: Colors.purple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFBF5FF),
    );
  }
}
