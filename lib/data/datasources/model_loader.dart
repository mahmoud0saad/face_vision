import 'package:flutter/services.dart';

/// Reads bundled package model bytes via Flutter [rootBundle].
class ModelLoader {
  Future<Uint8List> readAssetBytes(String relativePath) async {
    final data = await rootBundle.load('packages/face_vision_service/$relativePath');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
