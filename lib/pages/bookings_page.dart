import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import '../utils/flight_format.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, this.embedded = false});

  final bool embedded;
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
    _flightsMap = {for (var f in flights) f.id: f};
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _cancel(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đặt vé?'),
        content: const Text('Bạn có chắc muốn hủy vé này? Ghế sẽ được hoàn lại.'),
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
    if (confirm != true) return;
    final ok = await _api.cancelBooking(id);
    if (ok) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy đặt vé thành công'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showDetail(Booking b, Flight? flight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã vé ${b.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailLine('Hành khách', b.passengerName),
            if (flight != null) _detailLine('Hành trình', '${flight.from} → ${flight.to}'),
            _detailLine('Số ghế', '${b.seats}'),
            _detailLine('Ngày đặt', formatFlightDate(b.bookedAt)),
            _detailLine(
              'Trạng thái',
              b.status == 'cancelled' ? 'Đã hủy' : 'Đã xác nhận',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Đóng'),
                  ),
                ),
                if (b.status != 'cancelled') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _cancel(b.id);
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Hủy vé'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Vé đã đặt'),
        backgroundColor: const Color(0xFF00A884),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.embedded,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Chưa có vé nào', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Đặt chuyến bay từ trang tìm kiếm', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF00A884),
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final b = _bookings[i];
                      final flight = _flightsMap[b.flightId];
                      final cancelled = b.status == 'cancelled';
                      return Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => _showDetail(b, flight),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                if (flight != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      flightImageUrl(flight, width: 200, height: 120),
                                      width: 88,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 88,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.flight),
                                  ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        flight != null ? '${flight.from} → ${flight.to}' : b.flightId,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(b.passengerName, style: TextStyle(color: Colors.grey.shade700)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${b.seats} ghế · ${formatShortDate(b.bookedAt)}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cancelled ? Colors.red.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    cancelled ? 'Đã hủy' : 'OK',
                                    style: TextStyle(
                                      color: cancelled ? Colors.red : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
