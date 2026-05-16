import 'package:flutter/material.dart';
import '../models/flight.dart';

class FlightDetailPage extends StatelessWidget {
  final Flight flight;
  const FlightDetailPage({super.key, required this.flight});

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
            Text('Khởi hành: ${flight.depart.toLocal()}'),
            const SizedBox(height: 6),
            Text('Hạ cánh: ${flight.arrive.toLocal()}'),
            const SizedBox(height: 6),
            Text('Giá: \$${flight.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Chuyến bay chất lượng, phục vụ đồ ăn nhẹ, hành lý xách tay và tuỳ chọn hành lý ký gửi. Thời gian bay nhanh chóng và an toàn.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
          ],
        ),
      ),
    );
  }
}
