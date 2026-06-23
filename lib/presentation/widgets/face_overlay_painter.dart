import 'package:flutter/material.dart';

import '../../domain/entities/detected_frame.dart';
import '../../domain/entities/face.dart';

class FaceOverlayPainter extends CustomPainter {
  FaceOverlayPainter(this.frame, this.imageSize);

  final DetectedFrame frame;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final face in frame.faces) {
      _drawFace(canvas, size, face, scaleX, scaleY);
    }
  }

  void _drawFace(
    Canvas canvas,
    Size size,
    Face face,
    double scaleX,
    double scaleY,
  ) {
    final rect = Rect.fromLTWH(
      face.box.x * scaleX,
      face.box.y * scaleY,
      face.box.width * scaleX,
      face.box.height * scaleY,
    );

    final boxPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, boxPaint);

    final label = '#${face.id} ${face.gender.label}, ${face.age.label} | '
        'L:${face.leftEye.label} R:${face.rightEye.label}';
    const padding = EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelWidth = textPainter.width + padding.horizontal;
    final labelHeight = textPainter.height + padding.vertical;
    final labelX =
        rect.left.clamp(0.0, (size.width - labelWidth).clamp(0.0, double.infinity));
    final labelY = (rect.top - labelHeight - 4).clamp(0.0, double.infinity);
    final labelRect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()..color = const Color(0xCC000000),
    );

    textPainter.paint(
      canvas,
      Offset(labelX + padding.left, labelY + padding.top),
    );
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.imageSize != imageSize;
  }
}
