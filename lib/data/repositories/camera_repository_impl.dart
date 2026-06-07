import 'dart:typed_data';

import '../../domain/entities/raw_frame.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/opencv_camera_datasource.dart';

class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl(this._datasource);

  final OpenCvCameraDatasource _datasource;

  @override
  Future<void> open() => _datasource.open();

  @override
  Future<RawFrame?> grab() async {
    final result = _datasource.readFrame();
    if (result == null) return null;

    final (_, mat) = result;
    try {
      final bytes = Uint8List.fromList(mat.data);
      return RawFrame(
        bgrBytes: bytes,
        width: mat.cols,
        height: mat.rows,
      );
    } finally {
      mat.dispose();
    }
  }

  @override
  Future<void> close() => _datasource.close();
}
