import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key, this.embedded = false});

  final bool embedded;

  static const _primary = Color(0xFF00A884);

  Future<void> _launch(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được: $uri'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Liên hệ'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !embedded,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContactTile(
            icon: Icons.phone_in_talk,
            title: 'Hotline 24/7',
            subtitle: '1900 1234',
            onTap: () => _launch(context, Uri.parse('tel:19001234')),
          ),
          _ContactTile(
            icon: Icons.email_outlined,
            title: 'Email hỗ trợ',
            subtitle: 'support@udaair.vn',
            onTap: () => _launch(context, Uri.parse('mailto:support@udaair.vn')),
          ),
          _ContactTile(
            icon: Icons.chat_bubble_outline,
            title: 'Zalo / Live chat',
            subtitle: 'Phản hồi trong 5 phút',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang kết nối tổng đài ảo UDA Air...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _ContactTile(
            icon: Icons.location_on_outlined,
            title: 'Văn phòng',
            subtitle: '41 Lê Duẩn, Đà Nẵng',
            onTap: () => _launch(context, Uri.parse('https://maps.google.com/?q=Da+Nang')),
          ),
          const SizedBox(height: 16),
          const Text('Giờ làm việc', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('T2–T6: 8:00 – 20:00\nT7–CN: 9:00 – 17:00', style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF00A884).withValues(alpha: 0.12),
          child: Icon(icon, color: const Color(0xFF00A884), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
