import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/booking.dart';
import '../models/flight.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});
  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final ApiService _api = ApiService.instance;
  List<Booking> _bookings = [];
  Map<String, Flight> _flightsMap = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _bookings = await _api.getBookings();
    final flights = await _api.getFlights();
    _flightsMap = { for (var f in flights) f.id : f };
    if (!mounted) return;
    setState(() => _loading = false);
  }

  // (helper removed) flight lookup not required for listing

  Future<void> _cancel(String id) async {
    final ok = await _api.cancelBooking(id);
    if (ok) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy đặt vé thành công')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch đặt vé')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
            ? const Center(child: Text('Chưa có đặt vé nào'))
            : ListView.separated(
              itemCount: _bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = _bookings[i];
                  final flight = _flightsMap[b.flightId];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        showDialog(context: context, builder: (ctx) {
                          return AlertDialog(
                            title: Text('Booking ${b.id}'),
                            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Hành khách: ${b.passengerName}'),
                              const SizedBox(height: 6),
                              Text('Flight: ${b.flightId}'),
                              const SizedBox(height: 6),
                              if (flight != null) Text('${flight.from} → ${flight.to}'),
                              const SizedBox(height: 6),
                              Text('Ghế: ${b.seats}'),
                              const SizedBox(height: 6),
                              Text('Ngày đặt: ${b.bookedAt.toLocal()}'.split('.').first),
                              const SizedBox(height: 8),
                              Text('Trạng thái: ${b.status}', style: TextStyle(color: b.status == 'cancelled' ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                            ]),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
                              if (b.status != 'cancelled') TextButton(onPressed: () async { Navigator.pop(ctx); await _cancel(b.id); }, child: const Text('Hủy', style: TextStyle(color: Colors.red))),
                            ],
                          );
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://picsum.photos/120/80?random=$i', width: 120, height: 80, fit: BoxFit.cover)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(flight != null ? '${flight.from} → ${flight.to}' : 'Flight ${b.flightId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('Hành khách: ${b.passengerName}'),
                            const SizedBox(height: 4),
                            Text('Ghế: ${b.seats} • ${b.bookedAt.toLocal()}'.split('.').first),
                          ])),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: b.status == 'cancelled' ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(b.status.toUpperCase(), style: TextStyle(color: b.status == 'cancelled' ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
