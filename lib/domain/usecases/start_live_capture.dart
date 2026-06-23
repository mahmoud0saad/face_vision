import '../repositories/live_session_repository.dart';

class StartLiveCapture {
  StartLiveCapture(this._repository);

  final LiveSessionRepository _repository;

  Future<void> call({
    required double intervalSeconds,
    bool includePreviewJpeg = true,
  }) =>
      _repository.startLive(
        intervalSeconds: intervalSeconds,
        includePreviewJpeg: includePreviewJpeg,
      );
}
