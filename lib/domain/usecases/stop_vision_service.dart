import '../repositories/face_analysis_repository.dart';

class StopVisionService {
  StopVisionService(this._repository);

  final FaceAnalysisRepository _repository;

  Future<void> call() => _repository.stopService();
}
