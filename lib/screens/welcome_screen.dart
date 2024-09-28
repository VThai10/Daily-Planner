import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thêm logo vào phần trên
            Image.asset(
              'lib/assets/images/logo.png',  // Đường dẫn đến tệp logo
              width: 150,  // Điều chỉnh kích thước nếu cần
              height: 150,
            ),
            const SizedBox(height: 30),
            // Nút Đăng nhập
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
