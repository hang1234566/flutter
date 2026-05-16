import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../services/api_service.dart';

class FlightDetailPage extends StatelessWidget {
  final Flight flight;
  const FlightDetailPage({super.key, required this.flight});

  Future<void> _showBookingDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final seatsController = TextEditingController(text: '1');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đặt vé ${flight.from} → ${flight.to}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên hành khách')),
            const SizedBox(height: 12),
            TextField(controller: seatsController, decoration: const InputDecoration(labelText: 'Số ghế'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim().isEmpty ? 'Khách' : nameController.text.trim();
              final seats = int.tryParse(seatsController.text) ?? 1;
              try {
                final booking = await ApiService.instance.bookFlight(flight.id, name, seats);
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt vé thành công: ${booking.id}')));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đặt vé: ${e.toString()}')));
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${flight.from} → ${flight.to}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(tag: flight.id, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/800/300?random=${flight.id}', fit: BoxFit.cover, width: double.infinity, height: 200))),
            const SizedBox(height: 12),
            Text('${flight.from} → ${flight.to}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.calendar_today, size: 18, color: Colors.grey), const SizedBox(width: 8), Text('Khởi hành: ${flight.depart.toLocal()}')]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.schedule, size: 18, color: Colors.grey), const SizedBox(width: 8), Text('Hạ cánh: ${flight.arrive.toLocal()}')]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.attach_money, size: 18, color: Colors.grey), const SizedBox(width: 8), Text('Giá: \$${flight.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Chip(label: Text('Ghế còn: ${flight.seatsAvailable}'), backgroundColor: flight.seatsAvailable > 0 ? Colors.green.shade50 : Colors.red.shade50),
            const SizedBox(height: 16),
            const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Chuyến bay chất lượng, phục vụ đồ ăn nhẹ, hành lý xách tay và tuỳ chọn hành lý ký gửi. Trải nghiệm bay an toàn cùng dịch vụ chuyên nghiệp.'),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => _showBookingDialog(context), child: const Text('Đặt vé ngay'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại'))),
            ]),
          ],
        ),
      ),
    );
  }
}
