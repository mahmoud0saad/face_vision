import 'dart:typed_data';

/// Camera frame as raw BGR pixels (domain-only, no OpenCV types).
class RawFrame {
  const RawFrame({
    required this.bgrBytes,
    required this.width,
    required this.height,
  });

  final Uint8List bgrBytes;
  final int width;
  final int height;
}
