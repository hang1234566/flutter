import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import '../utils/flight_format.dart';

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  final ApiService _api = ApiService.instance;
  List<Booking> _active = [];
  Map<String, Flight> _flights = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _api.getBookings();
    final flights = await _api.getFlights();
    _flights = {for (final f in flights) f.id: f};
    _active = all.where((b) => b.status != 'cancelled').toList();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _cancel(Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy chuyến bay?'),
        content: Text('Hủy vé ${b.id}? Ghế sẽ được hoàn lại theo chính sách.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await _api.cancelBooking(b.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy chuyến thành công'), behavior: SnackBarBehavior.floating),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Hủy chuyến'),
        backgroundColor: const Color(0xFF00A884),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.embedded,
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)))
          : _active.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Không có vé để hủy', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Đặt vé trước tại tab Tìm vé', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _active.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final b = _active[i];
                    final f = _flights[b.flightId];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f != null ? '${f.from} → ${f.to}' : b.flightId,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${b.passengerName} · ${b.seats} ghế', style: const TextStyle(fontSize: 12)),
                                  if (f != null)
                                    Text(formatFlightDate(f.depart), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: () => _cancel(b),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Hủy', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
