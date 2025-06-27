class Schedule {
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  String? address;
  DateTime? notifyAt;

  Schedule({
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.address,
    this.notifyAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      eventId: json['event_id'],
      title: json['title'],
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: DateTime.parse(json['end_time']).toLocal(),
      location: json['location'],
      address: json['address'],
      notifyAt: json['notify_at'] != null
          ? DateTime.tryParse(json['notify_at'])?.toLocal()
          : null,
    );
  }
}
