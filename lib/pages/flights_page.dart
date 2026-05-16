import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import 'bookings_page.dart';
import 'flight_detail_page.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});
  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final ApiService _api = ApiService.instance;
  final _from = TextEditingController();
  final _to = TextEditingController();
  List<Flight> _flights = [];
  bool _loading = false;
  DateTime? _departDate;
  RangeValues _priceRange = const RangeValues(0, 1000);
  int _minSeats = 1;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    _flights = await _api.getFlights();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    _flights = await _api.searchFlights(
      _from.text,
      _to.text,
      departDate: _departDate,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minSeats: _minSeats,
    );
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) {
        DateTime? tmpDate = _departDate;
        RangeValues tmpRange = _priceRange;
        int tmpSeats = _minSeats;
        return StatefulBuilder(builder: (context, setSt) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Ngày khởi hành'),
                  subtitle: Text(tmpDate == null ? 'Bất kỳ' : '${tmpDate!.toLocal()}'.split(' ').first),
                  trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: tmpDate ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 0)), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setSt(() => tmpDate = d);
                  }),
                ),
                const SizedBox(height: 8),
                Row(children: [const Text('Khoảng giá:'), const SizedBox(width: 12), Text('\$${tmpRange.start.toInt()} - \$${tmpRange.end.toInt()}')]),
                RangeSlider(values: tmpRange, min: 0, max: 1000, divisions: 20, labels: RangeLabels('\$${tmpRange.start.toInt()}', '\$${tmpRange.end.toInt()}'), onChanged: (r) => setSt(() => tmpRange = r)),
                const SizedBox(height: 8),
                Row(children: [const Text('Số ghế tối thiểu:'), const SizedBox(width: 12), DropdownButton<int>(value: tmpSeats, items: List.generate(6, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}'))), onChanged: (v) => setSt(() => tmpSeats = v ?? 1))]),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: OutlinedButton(onPressed: () { setState(() { _departDate = null; _priceRange = const RangeValues(0,1000); _minSeats = 1; }); Navigator.pop(context); _search(); }, child: const Text('Xóa bộ lọc'))), const SizedBox(width: 8), ElevatedButton(onPressed: () { setState(() { _departDate = tmpDate; _priceRange = tmpRange; _minSeats = tmpSeats; }); Navigator.pop(context); _search(); }, child: const Text('Áp dụng'))])
              ]),
            ),
          );
        });
      }
    );
  }

  void _bookDialog(Flight f) {
    final name = TextEditingController();
    final seats = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Đặt vé ${f.id} ${f.from} → ${f.to}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên hành khách')),
            TextField(controller: seats, decoration: const InputDecoration(labelText: 'Số ghế'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final n = name.text.trim();
              final s = int.tryParse(seats.text) ?? 1;
              try {
                final booking = await _api.bookFlight(f.id, n.isEmpty ? 'Khách' : n, s);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt vé thành công (${booking.id})')));
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
              }
              await _search();
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
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(onPressed: _openFilter, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsPage())); }, icon: const Icon(Icons.schedule))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _from, decoration: const InputDecoration(prefixIcon: Icon(Icons.flight_takeoff), hintText: 'Nơi đi'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _to, decoration: const InputDecoration(prefixIcon: Icon(Icons.flight_land), hintText: 'Nơi đến'))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _search, child: const Icon(Icons.search)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _flights.isEmpty
                  ? const Center(child: Text('Không có chuyến nào'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisExtent: 140, childAspectRatio: 3),
                      itemCount: _flights.length,
                      itemBuilder: (context, i) {
                        final f = _flights[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlightDetailPage(flight: f))),
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Hero(tag: f.id, child: ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                  child: Image.network('https://picsum.photos/200/140?random=$i', width: 140, height: 140, fit: BoxFit.cover),
                                ),
                              ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${f.from} → ${f.to}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 6),
                                      Text('${f.depart}'.split('.').first, style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Chip(label: Text('\$${f.price.toStringAsFixed(0)}')),
                                        const SizedBox(width: 8),
                                        Text('Ghế: ${f.seatsAvailable}', style: const TextStyle(color: Colors.black87)),
                                      ])
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ElevatedButton(onPressed: f.seatsAvailable>0?() => _bookDialog(f):null, child: const Text('Đặt')),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
