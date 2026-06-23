import '../repositories/live_session_repository.dart';

class StopLiveCapture {
  StopLiveCapture(this._repository);

  final LiveSessionRepository _repository;

  Future<void> call() => _repository.stopLive();
}
