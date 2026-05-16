import 'package:flutter/material.dart';
import 'signin_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 2) {
      _controller.animateToPage(_index + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInPage())), child: const Text('Skip')),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (p) => setState(() => _index = p),
                children: [
                  _buildSlide('Tìm chuyến', 'Tìm chuyến bay nhanh chóng với giao diện trực quan', 'https://picsum.photos/800/600?image=100'),
                  _buildSlide('Đặt vé dễ dàng', 'Lựa chọn chỗ ngồi và thanh toán an toàn', 'https://picsum.photos/800/600?image=200'),
                  _buildSlide('Quản lý lịch', 'Xem lịch đặt và chỉnh sửa khi cần', 'https://picsum.photos/800/600?image=300'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Row(children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(horizontal:4), width: _index==i?18:8, height:8, decoration: BoxDecoration(color: _index==i?Colors.green:Colors.grey.shade300, borderRadius: BorderRadius.circular(8))))),
                  const Spacer(),
                  ElevatedButton(onPressed: _next, child: Text(_index < 2 ? 'Next' : 'Get Started')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(String title, String subtitle, String image) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(image, fit: BoxFit.cover, width: double.infinity))),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
