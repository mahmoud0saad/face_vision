# Face Vision (Flutter Windows)

On-device face detection with age and gender estimation using OpenCV DNN (`opencv_dart` 1.2.4).

## Architecture

- **Clean Architecture**: `lib/domain` (pure Dart), `lib/data` (OpenCV), `lib/presentation` (Provider + UI)
- **State management**: `provider` (`FaceVisionProvider`)
- Conventions: `.cursor/rules/architecture.mdc`

## Prerequisites

- Flutter 3.x with Windows desktop enabled
- Webcam with Windows camera privacy allowed for desktop apps
- Internet on first build (downloads prebuilt `opencv_dart.dll`)

## Run

```bash
cd face_vision
flutter pub get
flutter run -d windows
```

## Models

Pretrained models are bundled in `packages/face_vision_service/lib/assets/models/` (face SSD, age_net, gender_net). They are copied to a temp directory on first `start()`.

## Project layout

```
lib/
  core/           # constants
  domain/         # entities, repository interfaces, use cases
  data/           # OpenCV datasources, repository implementations
  presentation/   # provider, pages, widgets
  main.dart       # composition root (DI)
```
