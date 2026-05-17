import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'flights_shell.dart';
import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService.instance;
  bool _remember = false;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final success = await _apiService.login(_emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const FlightsShell()));
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
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 44, backgroundColor: Theme.of(context).primaryColor, child: const Icon(Icons.flight, size: 40, color: Colors.white)),
                      const SizedBox(height: 12),
                      const Text("Welcome back", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text("Đăng nhập để tiếp tục đặt vé", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                hintText: "you@example.com",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? 'Vui lòng nhập email' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                hintText: "Nhập mật khẩu",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordPage()));
                            },
                            child: Text('Quên mật khẩu?', style: TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (v) => setState(() => _remember = v ?? false),
                          ),
                          const Text('Ghi nhớ đăng nhập'),
                        ],
                      ),

                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
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