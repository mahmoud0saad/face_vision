import '../repositories/face_analysis_repository.dart';

class StartVisionService {
  StartVisionService(this._repository);

  final FaceAnalysisRepository _repository;

  Future<void> call() => _repository.startService();
}
