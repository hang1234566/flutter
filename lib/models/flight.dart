class Flight {
  final String id;
  final String from;
  final String to;
  final DateTime depart;
  final DateTime arrive;
  final double price;
  int seatsAvailable;

  Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.depart,
    required this.arrive,
    required this.price,
    required this.seatsAvailable,
  });
}
