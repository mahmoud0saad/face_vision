import 'dart:typed_data';

import 'face.dart';

class DetectedFrame {
  const DetectedFrame({
    required this.jpegBytes,
    required this.width,
    required this.height,
    required this.faces,
  });

  final Uint8List jpegBytes;
  final int width;
  final int height;
  final List<Face> faces;
}
