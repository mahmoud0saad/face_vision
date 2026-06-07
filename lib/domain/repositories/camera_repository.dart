import '../entities/raw_frame.dart';

abstract class CameraRepository {
  Future<void> open();
  Future<RawFrame?> grab();
  Future<void> close();
}
