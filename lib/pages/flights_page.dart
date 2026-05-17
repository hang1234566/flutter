import 'package:flutter/material.dart';

import '../models/flight.dart';
import '../services/api_service.dart';
import '../utils/flight_format.dart';
import '../widgets/booking_sheet.dart';
import '../widgets/city_picker_sheet.dart';
import 'bookings_page.dart';
import 'flight_detail_page.dart';

enum _SortMode { priceAsc, priceDesc, timeAsc }

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key, this.embedded = false});

  final bool embedded;
  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  static const _primary = Color(0xFF00A884);
  static const _primaryDark = Color(0xFF008F6F);

  final ApiService _api = ApiService.instance;
  final _from = TextEditingController();
  final _to = TextEditingController();

  List<Flight> _flights = [];
  List<Flight> _displayFlights = [];
  bool _loading = false;
  DateTime? _departDate;
  RangeValues _priceRange = const RangeValues(0, 1000);
  int _minSeats = 1;
  _SortMode _sort = _SortMode.priceAsc;
  bool _filterActive = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _applySortAndDisplay() {
    final list = List<Flight>.from(_flights);
    switch (_sort) {
      case _SortMode.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortMode.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _SortMode.timeAsc:
        list.sort((a, b) => a.depart.compareTo(b.depart));
    }
    _displayFlights = list;
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    _flights = await _api.getFlights();
    _applySortAndDisplay();
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
    _applySortAndDisplay();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _swapCities() {
    final tmp = _from.text;
    _from.text = _to.text;
    _to.text = tmp;
    setState(() {});
    _search();
  }

  Future<void> _pickCity(TextEditingController controller, String title) async {
    final picked = await showCityPickerSheet(context, title: title);
    if (picked != null) {
      controller.text = picked;
      setState(() {});
      _search();
    }
  }

  Future<void> _pickDepartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _departDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Ngày khởi hành',
    );
    if (d != null) {
      setState(() => _departDate = d);
      _search();
    }
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        DateTime? tmpDate = _departDate;
        RangeValues tmpRange = _priceRange;
        int tmpSeats = _minSeats;
        return StatefulBuilder(
          builder: (context, setSt) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text('Bộ lọc nâng cao', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month, color: _primary),
                      title: const Text('Ngày khởi hành'),
                      subtitle: Text(formatShortDate(tmpDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: tmpDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setSt(() => tmpDate = d);
                      },
                    ),
                    if (tmpDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setSt(() => tmpDate = null),
                          child: const Text('Xóa ngày'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text('Khoảng giá: ${formatPrice(tmpRange.start)} – ${formatPrice(tmpRange.end)}'),
                    RangeSlider(
                      values: tmpRange,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      activeColor: _primary,
                      labels: RangeLabels(
                        formatPrice(tmpRange.start),
                        formatPrice(tmpRange.end),
                      ),
                      onChanged: (r) => setSt(() => tmpRange = r),
                    ),
                    Row(
                      children: [
                        const Text('Ghế tối thiểu'),
                        const Spacer(),
                        DropdownButton<int>(
                          value: tmpSeats,
                          items: List.generate(
                            6,
                            (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}+')),
                          ),
                          onChanged: (v) => setSt(() => tmpSeats = v ?? 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _departDate = null;
                                _priceRange = const RangeValues(0, 1000);
                                _minSeats = 1;
                                _filterActive = false;
                              });
                              Navigator.pop(context);
                              _search();
                            },
                            child: const Text('Đặt lại'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _departDate = tmpDate;
                                _priceRange = tmpRange;
                                _minSeats = tmpSeats;
                                _filterActive = tmpDate != null ||
                                    tmpRange.start > 0 ||
                                    tmpRange.end < 1000 ||
                                    tmpSeats > 1;
                              });
                              Navigator.pop(context);
                              _search();
                            },
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openBookings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsPage()));
    if (!mounted) return;
    await _search();
  }

  Future<void> _book(Flight f) async {
    if (f.seatsAvailable < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyến bay đã hết chỗ')),
      );
      return;
    }
    final ok = await showFlightBookingSheet(context, f, onSuccess: _search);
    if (ok == true && mounted) await _search();
  }

  void _openDetail(Flight f) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlightDetailPage(flight: f)),
    ).then((_) {
      if (mounted) _search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: widget.embedded ? 88 : 100,
            pinned: true,
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            leading: widget.embedded
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
            automaticallyImplyLeading: !widget.embedded,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tìm chuyến bay',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${_displayFlights.length} chuyến khả dụng',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Bộ lọc',
                onPressed: _openFilter,
                icon: Badge(
                  isLabelVisible: _filterActive,
                  smallSize: 8,
                  child: const Icon(Icons.tune),
                ),
              ),
              if (!widget.embedded)
                IconButton(
                  tooltip: 'Vé đã đặt',
                  onPressed: _openBookings,
                  icon: const Icon(Icons.confirmation_number_outlined),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, widget.embedded ? -12 : -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchCard(
                  from: _from,
                  to: _to,
                  departLabel: formatShortDate(_departDate),
                  onPickFrom: () => _pickCity(_from, 'Chọn điểm đi'),
                  onPickTo: () => _pickCity(_to, 'Chọn điểm đến'),
                  onPickDate: _pickDepartDate,
                  onSwap: _swapCities,
                  onSearch: _search,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Text('Sắp xếp', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Giá thấp',
                    selected: _sort == _SortMode.priceAsc,
                    onTap: () {
                      setState(() {
                        _sort = _SortMode.priceAsc;
                        _applySortAndDisplay();
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  _SortChip(
                    label: 'Giá cao',
                    selected: _sort == _SortMode.priceDesc,
                    onTap: () {
                      setState(() {
                        _sort = _SortMode.priceDesc;
                        _applySortAndDisplay();
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  _SortChip(
                    label: 'Sớm nhất',
                    selected: _sort == _SortMode.timeAsc,
                    onTap: () {
                      setState(() {
                        _sort = _SortMode.timeAsc;
                        _applySortAndDisplay();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else if (_displayFlights.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(onReset: () {
                _from.clear();
                _to.clear();
                setState(() {
                  _departDate = null;
                  _filterActive = false;
                });
                _loadAll();
              }),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, widget.embedded ? 8 : 24),
              sliver: SliverList.separated(
                itemCount: _displayFlights.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final f = _displayFlights[i];
                  return _FlightCard(
                    flight: f,
                    index: i,
                    onTap: () => _openDetail(f),
                    onBook: () => _book(f),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.from,
    required this.to,
    required this.departLabel,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onPickDate,
    required this.onSwap,
    required this.onSearch,
  });

  final TextEditingController from;
  final TextEditingController to;
  final String departLabel;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onPickDate;
  final VoidCallback onSwap;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _CompactCityTap(label: 'Đi', controller: from, onTap: onPickFrom)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Đổi chiều',
                      onPressed: onSwap,
                      icon: const Icon(Icons.swap_horiz, size: 20, color: Color(0xFF00A884)),
                    ),
                  ),
                  Expanded(child: _CompactCityTap(label: 'Đến', controller: to, onTap: onPickTo)),
                  const SizedBox(width: 6),
                  _CompactDateTap(label: departLabel, onTap: onPickDate),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                onPressed: onSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00A884),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tìm chuyến', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCityTap extends StatelessWidget {
  const _CompactCityTap({required this.label, required this.controller, required this.onTap});

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCity = controller.text.isNotEmpty;
    return Material(
      color: const Color(0xFFF4F7F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(
                hasCity ? cityCode(controller.text) : '—',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00A884)),
              ),
              Text(
                hasCity ? controller.text : 'Chọn',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: hasCity ? Colors.black87 : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactDateTap extends StatelessWidget {
  const _CompactDateTap({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ngày', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF00A884)),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF00A884).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF00A884),
    );
  }
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({
    required this.flight,
    required this.index,
    required this.onTap,
    required this.onBook,
  });

  final Flight flight;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final soldOut = flight.seatsAvailable < 1;
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Hero(
                tag: flight.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    flightImageUrl(flight, width: 160, height: 160),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFFE8FBF4),
                      child: const Icon(Icons.flight, color: Color(0xFF00A884)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cityCode(flight.from),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade500),
                        ),
                        Text(
                          cityCode(flight.to),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(flight.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A884),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${flight.from} → ${flight.to}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatFlightDate(flight.depart),
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          formatDuration(flight.depart, flight.arrive),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          soldOut ? 'Hết chỗ' : '${flight.seatsAvailable} ghế',
                          style: TextStyle(
                            fontSize: 10,
                            color: soldOut ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: soldOut ? null : onBook,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00A884),
                      minimumSize: const Size(56, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Đặt', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy chuyến bay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử đổi điểm đi/đến hoặc bỏ bộ lọc ngày và giá.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Xem tất cả chuyến'),
            ),
          ],
        ),
      ),
    );
  }
}
