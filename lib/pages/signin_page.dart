import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final ApiService _apiService = ApiService.instance;
  bool _remember = false;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final success = await _apiService.login(_user.text.trim(), _pass.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thông tin đăng nhập không chính xác!"),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8FBF4), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded, size: 72, color: Color(0xFF00C59E)),
                      const SizedBox(height: 12),
                      const Text("ĐĂNG NHẬP UDA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00C59E))),
                      const SizedBox(height: 8),
                      const Text("Vui lòng nhập thông tin để tiếp tục", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),

                      // Ô nhập Mã số sinh viên
                      TextField(
                        controller: _user,
                        decoration: InputDecoration(
                          labelText: "Mã số sinh viên",
                          hintText: "Nhập mã số sinh viên của bạn",
                          prefixIcon: const Icon(Icons.person_outline),
                          helperText: 'Ví dụ: 106010',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập Mật khẩu
                      TextField(
                        controller: _pass,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          hintText: "Nhập mật khẩu",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true, // Hiện dấu chấm bảo mật
                      ),

                      const SizedBox(height: 8),
                      // Nút Quên mật khẩu (canh phải)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordPage()));
                            },
                            child: const Text('Quên mật khẩu?', style: TextStyle(color: Color(0xFF00C59E))),
                          ),
                        ],
                      ),

                      // Remember me + login button
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            activeColor: const Color(0xFF00C59E),
                            onChanged: (v) => setState(() => _remember = v ?? false),
                          ),
                          const Text('Ghi nhớ đăng nhập'),
                        ],
                      ),

                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C59E),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("VÀO HỆ THỐNG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 16),
                      const Text('Hoặc đăng nhập bằng', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)),
                            label: const Text('Google'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                            label: const Text('Facebook'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Cần hỗ trợ? Liên hệ bộ phận kỹ thuật trong mục Quên mật khẩu.', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}