import '../entities/detected_frame.dart';
import '../entities/raw_frame.dart';

abstract class FaceAnalysisRepository {
  bool get isServiceRunning;

  Future<void> startService();
  Future<void> stopService();
  Future<DetectedFrame> analyze(RawFrame frame);
  Future<void> resetTracker();
}
