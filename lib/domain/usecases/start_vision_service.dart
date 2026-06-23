import '../repositories/live_session_repository.dart';

class StartVisionService {
  StartVisionService(this._repository);

  final LiveSessionRepository _repository;

  Future<void> call({
    void Function(String stage, double? progress)? onProgress,
  }) =>
      _repository.startService(onProgress: onProgress);
}
