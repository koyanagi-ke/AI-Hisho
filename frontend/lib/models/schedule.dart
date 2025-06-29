import 'package:app/utils/date_format_utils.dart';

class Schedule {
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? address;
  final DateTime? notifyAt;

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
    final now = DateTime.now();
    final start = json['start_time'] != null
        ? DateTime.tryParse(json['start_time'])?.toLocal() ?? now
        : now;

    final end = json['end_time'] != null
        ? DateTime.tryParse(json['end_time'])?.toLocal() ??
            start.add(const Duration(hours: 1))
        : start.add(const Duration(hours: 1));
    return Schedule(
      eventId: json['event_id'] ?? '',
      title: json['title'] ?? '',
      startTime: start,
      endTime: end,
      location: json['location'] ?? '',
      address: json['address'],
      notifyAt: json['notify_at'] != null
          ? DateTime.tryParse(json['notify_at'])?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'start_time': toIso8601WithOffset(startTime),
      'end_time': toIso8601WithOffset(endTime),
      'location': location,
      if (address != null) 'address': address,
      if (notifyAt != null) 'notify_at': toIso8601WithOffset(notifyAt!),
    };
  }

  factory Schedule.empty() {
    final now = DateTime.now();
    return Schedule(
      eventId: '',
      title: '',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      location: '',
    );
  }

  Schedule copyWith({
    String? eventId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? address,
    DateTime? notifyAt,
  }) {
    return Schedule(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      address: address ?? this.address,
      notifyAt: notifyAt ?? this.notifyAt,
    );
  }
}
