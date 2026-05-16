class Booking {
  final String id;
  final String flightId;
  final String passengerName;
  final DateTime bookedAt;
  final int seats;
  String status; // e.g., confirmed, cancelled

  Booking({
    required this.id,
    required this.flightId,
    required this.passengerName,
    required this.bookedAt,
    required this.seats,
    this.status = 'confirmed',
  });
}
