import '../repositories/live_session_repository.dart';

class StopVisionService {
  StopVisionService(this._repository);

  final LiveSessionRepository _repository;

  Future<void> call() => _repository.stopService();
}
