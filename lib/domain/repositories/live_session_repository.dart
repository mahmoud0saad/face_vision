import '../entities/detected_frame.dart';

abstract class LiveSessionRepository {
  bool get isServiceRunning;
  bool get isLiveRunning;
  Stream<DetectedFrame> get results;

  Future<void> startService({
    void Function(String stage, double? progress)? onProgress,
  });

  Future<void> stopService();

  Future<void> startLive({
    required double intervalSeconds,
    bool includePreviewJpeg = true,
  });

  Future<void> stopLive();

  Future<void> resetTracker();
}
