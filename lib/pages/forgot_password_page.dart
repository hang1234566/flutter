import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService.instance;
  String _feedback = '';
  bool _loading = false;

  Future<void> _requestReset() async {
    setState(() {
      _loading = true;
      _feedback = '';
    });
    final result = await _apiService.forgotPassword(_emailController.text.trim());
    setState(() {
      _loading = false;
      _feedback = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String hotline = '0123 456 789';
    final String email = 'support@uda.edu.vn';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: const Color(0xFF00C59E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_open, size: 64, color: Color(0xFF00C59E)),
                const SizedBox(height: 16),
                const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00C59E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập email để nhận hướng dẫn cấp lại mật khẩu hoặc liên hệ bộ phận hỗ trợ.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email của bạn',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _requestReset,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C59E)),
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('GỬI YÊU CẦU'),
                  ),
                ),
                if (_feedback.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(_feedback, style: const TextStyle(color: Colors.black87)),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF00C59E)),
                  title: const Text('Hotline hỗ trợ'),
                  subtitle: Text(hotline),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF00C59E)),
                  title: const Text('Email hỗ trợ'),
                  subtitle: Text(email),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: email));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép email hỗ trợ vào clipboard')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C59E)),
                  child: const Text('Sao chép email hỗ trợ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
