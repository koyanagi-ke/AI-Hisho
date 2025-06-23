import 'package:app/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

void showCustomToast(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.black87,
  Color textColor = Colors.white,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => CustomToast(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
