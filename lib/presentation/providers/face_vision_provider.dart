import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/detected_frame.dart';
import '../../domain/entities/face_snapshot.dart';
import '../../domain/repositories/live_session_repository.dart';
import '../../domain/usecases/reset_tracker.dart';
import '../../domain/usecases/start_live_capture.dart';
import '../../domain/usecases/start_vision_service.dart';
import '../../domain/usecases/stop_live_capture.dart';
import '../../domain/usecases/stop_vision_service.dart';

class FaceVisionProvider extends ChangeNotifier {
  FaceVisionProvider({
    required StartVisionService startVisionService,
    required StopVisionService stopVisionService,
    required StartLiveCapture startLiveCapture,
    required StopLiveCapture stopLiveCapture,
    required ResetTracker resetTracker,
    required LiveSessionRepository liveSessionRepository,
  })  : _startVisionService = startVisionService,
        _stopVisionService = stopVisionService,
        _startLiveCapture = startLiveCapture,
        _stopLiveCapture = stopLiveCapture,
        _resetTracker = resetTracker,
        _liveSessionRepository = liveSessionRepository;

  static const double _liveIntervalSeconds = 2.0;

  final StartVisionService _startVisionService;
  final StopVisionService _stopVisionService;
  final StartLiveCapture _startLiveCapture;
  final StopLiveCapture _stopLiveCapture;
  final ResetTracker _resetTracker;
  final LiveSessionRepository _liveSessionRepository;

  StreamSubscription<DetectedFrame>? _resultsSub;

  DetectedFrame? lastResult;
  final List<FaceSnapshot> _retainedPreviews = [];
  final Set<int> _seenFaceIdsThisSession = {};
  List<FaceSnapshot> get accumulatedFaces =>
      List<FaceSnapshot>.unmodifiable(_retainedPreviews);
  String? errorMessage;
  bool isBootstrapping = false;
  bool isStartingCapture = false;
  bool isServiceRunning = false;
  bool isStoppingService = false;
  bool isLiveScanning = false;
  bool isWaitingForFirstFrame = false;

  Future<void> bootstrapVision() async {
    if (isServiceRunning || isBootstrapping || isStoppingService) return;
    isBootstrapping = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _startVisionService();
      isServiceRunning = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> startCapture() async {
    if (!isServiceRunning ||
        isStartingCapture ||
        isStoppingService ||
        isLiveScanning) {
      return;
    }
    isStartingCapture = true;
    isWaitingForFirstFrame = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _startLiveCapture(
        intervalSeconds: _liveIntervalSeconds,
      
        includePreviewJpeg: true,
      );
      isLiveScanning = true;
      _subscribeToResults();
    } catch (e) {
      errorMessage = e.toString();
      isWaitingForFirstFrame = false;
      await _stopLiveCapture();
      isLiveScanning = false;
    } finally {
      isStartingCapture = false;
      notifyListeners();
    }
  }

  Future<void> stopCapture() async {
    if (!isLiveScanning && !isStartingCapture && !isWaitingForFirstFrame) return;
    if (isStoppingService) return;
    isStoppingService = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _unsubscribeAndStopLive();
      _clearLiveFrame();
      isWaitingForFirstFrame = false;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isStoppingService = false;
      notifyListeners();
    }
  }

  Future<void> stopService() async {
    if (!isServiceRunning &&
        !isBootstrapping &&
        !isStartingCapture &&
        !isLiveScanning) {
      return;
    }
    if (isStoppingService) return;
    isStoppingService = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _unsubscribeAndStopLive();
      if (isServiceRunning) {
        await _stopVisionService();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isServiceRunning = false;
      isStoppingService = false;
      _clearLiveFrame();
      notifyListeners();
    }
  }

  void _subscribeToResults() {
    _resultsSub?.cancel();
    _resultsSub = _liveSessionRepository.results.listen(
      (frame) {
        errorMessage = null;
        lastResult = frame;
        _mergeFacesFromFrame(frame);
        isWaitingForFirstFrame = false;
        notifyListeners();
      },
      onError: (Object e) {
        errorMessage = e.toString();
        isWaitingForFirstFrame = false;
        notifyListeners();
      },
    );
  }

  Future<void> _unsubscribeAndStopLive() async {
    await _resultsSub?.cancel();
    _resultsSub = null;
    isLiveScanning = false;
    if (_liveSessionRepository.isLiveRunning) {
      await _stopLiveCapture();
    }
  }

  Future<void> resetSession() async {
    if (!isServiceRunning) return;
    await _resetTracker();
    _clearPreviews();
    notifyListeners();
  }

  void _mergeFacesFromFrame(DetectedFrame frame) {
    for (final face in frame.faces) {
      if (_seenFaceIdsThisSession.contains(face.id)) continue;
      _seenFaceIdsThisSession.add(face.id);
      _retainedPreviews.add(
        FaceSnapshot(
          face: face,
          jpegBytes: frame.jpegBytes,
          frameWidth: frame.width,
          frameHeight: frame.height,
        ),
      );
    }
  }

  void _clearLiveFrame() {
    lastResult = null;
  }

  void _clearPreviews() {
    lastResult = null;
    _retainedPreviews.clear();
    _seenFaceIdsThisSession.clear();
  }

  @override
  void dispose() {
    unawaited(_unsubscribeAndStopLive());
    if (isServiceRunning) {
      unawaited(_stopVisionService());
    }
    super.dispose();
  }
}
