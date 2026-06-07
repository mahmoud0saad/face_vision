import 'package:opencv_dart/opencv_dart.dart' as cv;

const int _kCameraWidth = 640;
const int _kCameraHeight = 480;

class OpenCvCameraDatasource {
  cv.VideoCapture? _capture;

  Future<void> open({int deviceIndex = 0}) async {
    _capture?.release();
    _capture?.dispose();
    _capture = cv.VideoCapture.fromDevice(deviceIndex);
    if (!_capture!.isOpened) {
      throw StateError('Could not open camera at index $deviceIndex');
    }
    _capture!.set(cv.CAP_PROP_FRAME_WIDTH, _kCameraWidth.toDouble());
    _capture!.set(cv.CAP_PROP_FRAME_HEIGHT, _kCameraHeight.toDouble());
  }

  (bool, cv.Mat)? readFrame() {
    final cap = _capture;
    if (cap == null || !cap.isOpened) return null;
    final (ok, frame) = cap.read();
    if (!ok || frame.isEmpty) {
      frame.dispose();
      return null;
    }
    return (ok, frame);
  }

  Future<void> close() async {
    _capture?.release();
    _capture?.dispose();
    _capture = null;
  }
}
