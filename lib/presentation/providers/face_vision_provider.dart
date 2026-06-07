import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/capture_constants.dart';
import '../../domain/entities/detected_frame.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/repositories/face_analysis_repository.dart';
import '../../domain/usecases/analyze_image.dart';
import '../../domain/usecases/start_vision_service.dart';
import '../../domain/usecases/stop_vision_service.dart';

class FaceVisionProvider extends ChangeNotifier {
  FaceVisionProvider({
    required StartVisionService startVisionService,
    required StopVisionService stopVisionService,
    required AnalyzeImage analyzeImage,
    required CameraRepository camera,
    required FaceAnalysisRepository analysisRepository,
  })  : _startVisionService = startVisionService,
        _stopVisionService = stopVisionService,
        _analyzeImage = analyzeImage,
        _camera = camera,
        _analysisRepository = analysisRepository;

  final StartVisionService _startVisionService;
  final StopVisionService _stopVisionService;
  final AnalyzeImage _analyzeImage;
  final CameraRepository _camera;
  final FaceAnalysisRepository _analysisRepository;

  Timer? _captureTimer;

  DetectedFrame? lastResult;
  String? errorMessage;
  bool isStartingService = false;
  bool isServiceRunning = false;
  bool isStoppingService = false;
  bool isAnalyzing = false;
  bool isLiveScanning = false;
  bool isCameraOpen = false;

  Future<void> startService() async {
    if (isServiceRunning || isStartingService || isStoppingService) return;
    isStartingService = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _startVisionService();
      isServiceRunning = true;

      await _camera.open();
      isCameraOpen = true;
      _startLiveScan();
    } catch (e) {
      errorMessage = e.toString();
      if (isServiceRunning) {
        await _stopLiveScan();
        try {
          await _stopVisionService();
        } catch (_) {}
        isServiceRunning = false;
      }
    } finally {
      isStartingService = false;
      notifyListeners();
    }
  }

  Future<void> stopService() async {
    if (!isServiceRunning && !isStartingService && !isLiveScanning) return;
    if (isStoppingService) return;
    isStoppingService = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _stopLiveScan();
      if (isServiceRunning) {
        await _stopVisionService();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isServiceRunning = false;
      isStoppingService = false;
      lastResult = null;
      notifyListeners();
    }
  }

  void _startLiveScan() {
    _captureTimer?.cancel();
    isLiveScanning = true;
    unawaited(_captureTick());
    _captureTimer = Timer.periodic(
      const Duration(milliseconds: kAutoCaptureIntervalMs),
      (_) => unawaited(_captureTick()),
    );
  }

  Future<void> _stopLiveScan() async {
    _captureTimer?.cancel();
    _captureTimer = null;
    isLiveScanning = false;

    if (isCameraOpen) {
      await _camera.close();
      isCameraOpen = false;
    }
  }

  Future<void> _captureTick() async {
    if (!isServiceRunning || isStoppingService || isAnalyzing) return;
    if (!isCameraOpen) return;

    isAnalyzing = true;
    notifyListeners();

    try {
      final frame = await _camera.grab();
      if (frame == null) {
        errorMessage = 'Failed to capture frame from camera.';
      } else {
        errorMessage = null;
        lastResult = await _analyzeImage(frame);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> resetSession() async {
    if (!isServiceRunning) return;
    await _analysisRepository.resetTracker();
    lastResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_stopLiveScan());
    if (isServiceRunning) {
      unawaited(_stopVisionService());
    }
    super.dispose();
  }
}
