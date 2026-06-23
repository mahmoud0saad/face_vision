import 'package:face_vision_service/face_vision_service.dart';

import '../../domain/entities/age_range.dart';
import '../../domain/entities/detected_frame.dart';
import '../../domain/entities/eye_state.dart';
import '../../domain/entities/face.dart';
import '../../domain/entities/face_box.dart';
import '../../domain/entities/gender.dart';
import '../../domain/repositories/live_session_repository.dart';

class LiveSessionRepositoryImpl implements LiveSessionRepository {
  LiveSessionRepositoryImpl(this._session);

  final FaceVisionLiveSession _session;

  @override
  bool get isServiceRunning => _session.client.isRunning;

  @override
  bool get isLiveRunning => _session.isRunning;

  @override
  Stream<DetectedFrame> get results =>
      _session.results.map(_toDetectedFrame);

  @override
  Future<void> startService({
    void Function(String stage, double? progress)? onProgress,
  }) =>
      _session.client.start(onStartupProgress: onProgress);

  @override
  Future<void> stopService() => _session.dispose();

  @override
  Future<void> startLive({
    required double intervalSeconds,
    bool includePreviewJpeg = true,
  }) =>
      _session.start(
        intervalSeconds: intervalSeconds,
        includePreviewJpeg: includePreviewJpeg,
      );

  @override
  Future<void> stopLive() => _session.stop();

  @override
  Future<void> resetTracker() => _session.client.resetTracker();

  DetectedFrame _toDetectedFrame(FaceAnalysisResult result) {
    final jpeg = result.previewJpeg;
    if (jpeg == null) {
      throw StateError('Preview JPEG missing from live session result.');
    }

    return DetectedFrame(
      jpegBytes: jpeg,
      width: result.width,
      height: result.height,
      faces: result.faces.map(_mapFace).toList(),
    );
  }

  Face _mapFace(DetectedFace f) => Face(
        id: f.id,
        box: FaceBox(x: f.x, y: f.y, width: f.width, height: f.height),
        gender: f.genderLabel == 'F' ? Gender.female : Gender.male,
        age: AgeRange(f.ageLabel),
        detectionScore: f.detectionScore,
        leftEye: EyeState.fromLabel(f.leftEyeState),
        rightEye: EyeState.fromLabel(f.rightEyeState),
      );
}
