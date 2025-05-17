import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShadowedImage extends StatefulWidget {
  final String assetPath;

  const ShadowedImage({required this.assetPath, super.key});

  @override
  State<ShadowedImage> createState() => _ShadowedImageState();
}

class _ShadowedImageState extends State<ShadowedImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load(widget.assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ShadowPainter(_image!),
        );
      },
    );
  }
}

class ShadowPainter extends CustomPainter {
  final ui.Image image;

  ShadowPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // 描画先サイズ（親ウィジェットの size）に収まるようにスケーリング（BoxFit.contain相当）
    final scale = (size.width / imageWidth).clamp(0.0, 1.0);
    final scaleY = (size.height / imageHeight).clamp(0.0, 1.0);
    final fitScale = scale < scaleY ? scale : scaleY;

    final drawWidth = imageWidth * fitScale;
    final drawHeight = imageHeight * fitScale;

    final offsetX = (size.width - drawWidth) / 2;
    final offsetY = (size.height - drawHeight) / 2;

    final dstRect = Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight);

    // シャドウ（ちょっと下にずらして）
    final shadowPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4)
      ..colorFilter =
          const ui.ColorFilter.mode(Colors.black38, BlendMode.srcIn);
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        dstRect.shift(const Offset(3, 3)), shadowPaint);

    final imagePaint = Paint();
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        dstRect, imagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
