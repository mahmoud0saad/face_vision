import 'package:face_vision_service/face_vision_service.dart';

import '../../domain/entities/age_range.dart';
import '../../domain/entities/detected_frame.dart';
import '../../domain/entities/eye_state.dart';
import '../../domain/entities/face.dart';
import '../../domain/entities/face_box.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/raw_frame.dart';
import '../../domain/repositories/face_analysis_repository.dart';
class FaceAnalysisRepositoryImpl implements FaceAnalysisRepository {
  FaceAnalysisRepositoryImpl(this._client);

  final FaceVisionServiceClient _client;

  @override
  bool get isServiceRunning => _client.isRunning;

  @override
  Future<void> startService() => _client.start();

  @override
  Future<void> stopService() => _client.dispose();

  @override
  Future<DetectedFrame> analyze(RawFrame frame) async {
    if (!isServiceRunning) {
      throw StateError('Vision service is not running. Call startService() first.');
    }

    final result = await _client.analyze(
      RawImage(
        bgrBytes: frame.bgrBytes,
        width: frame.width,
        height: frame.height,
      ),
    );

    return DetectedFrame(
      jpegBytes: result.previewJpeg!,
      width: result.width,
      height: result.height,
      faces: result.faces.map(_mapFace).toList(),
    );
  }

  @override
  Future<void> resetTracker() => _client.resetTracker();

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
