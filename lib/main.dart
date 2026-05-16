import 'package:flutter/material.dart';
import 'pages/signin_page.dart'; // Import trang đăng nhập vào

void main() => runApp(const UdaApp());

class UdaApp extends StatelessWidget {
  const UdaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF00C59E)),
      home: const SignInPage(), // Chạy trang đăng nhập đầu tiên
    );
  }
}