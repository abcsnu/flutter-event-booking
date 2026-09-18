// lib/data/event_model.dart

class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final int availableSeats;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.availableSeats,
  });
}
