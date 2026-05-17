import 'package:flutter/material.dart';

import '../models/flight.dart';
import '../utils/flight_format.dart';
import '../widgets/booking_sheet.dart';

class FlightDetailPage extends StatefulWidget {
  final Flight flight;
  const FlightDetailPage({super.key, required this.flight});

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  Flight get flight => widget.flight;

  Future<void> _book() async {
    final ok = await showFlightBookingSheet(context, flight, onSuccess: () {
      if (mounted) setState(() {});
    });
    if (ok == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final soldOut = flight.seatsAvailable < 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF00A884),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: flight.id,
                    child: Image.network(
                      flightImageUrl(flight, width: 1200, height: 600),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF00A884),
                        child: const Icon(Icons.flight, size: 80, color: Colors.white54),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${flight.from} → ${flight.to}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UDA Air · ${flight.id}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Khởi hành',
                        value: formatFlightDate(flight.depart),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.flight_land_outlined,
                        title: 'Hạ cánh',
                        value: formatFlightDate(flight.arrive),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.timelapse_outlined,
                        title: 'Thời gian bay',
                        value: formatDuration(flight.depart, flight.arrive),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    children: [
                      Row(
                        children: [
                          const Text('Giá vé / ghế', style: TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text(
                            formatPrice(flight.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00A884),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.event_seat,
                            color: soldOut ? Colors.red : const Color(0xFF00A884),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            soldOut ? 'Đã hết chỗ' : 'Còn ${flight.seatsAvailable} ghế trống',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: soldOut ? Colors.red : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dịch vụ chuyến bay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    children: [
                      _ServiceTile(icon: Icons.luggage, text: 'Hành lý xách tay 7kg'),
                      _ServiceTile(icon: Icons.restaurant, text: 'Suất ăn nhẹ trên máy bay'),
                      _ServiceTile(icon: Icons.wifi, text: 'Wi‑Fi (mua thêm)'),
                      _ServiceTile(icon: Icons.verified_user, text: 'Bảo hiểm hành trình cơ bản'),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Quay lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: soldOut ? null : _book,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(soldOut ? 'Hết chỗ' : 'Đặt vé · ${formatPrice(flight.price)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00A884)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00A884)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
