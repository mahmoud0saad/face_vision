import 'dart:typed_data';

import 'face.dart';

class FaceSnapshot {
  const FaceSnapshot({
    required this.face,
    required this.jpegBytes,
    required this.frameWidth,
    required this.frameHeight,
  });

  final Face face;
  final Uint8List jpegBytes;
  final int frameWidth;
  final int frameHeight;
}
