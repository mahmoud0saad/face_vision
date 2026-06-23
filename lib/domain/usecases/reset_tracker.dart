import '../repositories/live_session_repository.dart';

class ResetTracker {
  ResetTracker(this._repository);

  final LiveSessionRepository _repository;

  Future<void> call() => _repository.resetTracker();
}
