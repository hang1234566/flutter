import '../models/flight.dart';

const kFlightCities = [
  'Hanoi',
  'Ho Chi Minh',
  'Da Nang',
  'Phu Quoc',
  'Nha Trang',
  'Hue',
  'Can Tho',
  'Hai Phong',
  'Da Lat',
  'Quy Nhon',
];

const Map<String, String> kCityCodes = {
  'Hanoi': 'HAN',
  'Ho Chi Minh': 'SGN',
  'Da Nang': 'DAD',
  'Phu Quoc': 'PQC',
  'Nha Trang': 'CXR',
  'Hue': 'HUI',
  'Can Tho': 'VCA',
  'Hai Phong': 'HPH',
  'Da Lat': 'DLI',
  'Quy Nhon': 'UIH',
};

String cityCode(String city) => kCityCodes[city] ?? city.substring(0, 3).toUpperCase();

String flightImageUrl(Flight flight, {int width = 400, int height = 280}) {
  final seed = '${flight.from}_${flight.to}'.hashCode.abs();
  return 'https://picsum.photos/seed/$seed/$width/$height';
}

String formatFlightDate(DateTime dt) {
  const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  const months = [
    'Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6',
    'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12',
  ];
  final w = days[dt.weekday % 7];
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$w, ${dt.day} ${months[dt.month - 1]} · $h:$m';
}

String formatShortDate(DateTime? dt) {
  if (dt == null) return 'Ngày đi';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

String formatDuration(DateTime depart, DateTime arrive) {
  final d = arrive.difference(depart);
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0 && m > 0) return '${h}g ${m}p';
  if (h > 0) return '${h}g';
  return '${m}p';
}

String formatPrice(double price) => '\$${price.toStringAsFixed(0)}';
