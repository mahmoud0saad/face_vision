import '../entities/detected_frame.dart';
import '../entities/raw_frame.dart';
import '../repositories/face_analysis_repository.dart';

class AnalyzeImage {
  AnalyzeImage(this._repository);

  final FaceAnalysisRepository _repository;

  Future<DetectedFrame> call(RawFrame frame) => _repository.analyze(frame);
}
