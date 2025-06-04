String toIso8601WithOffset(DateTime dateTime) {
  final offset = dateTime.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final isoString = dateTime.toIso8601String();
  return '$isoString$sign$hours:$minutes';
}
