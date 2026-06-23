import 'package:face_vision_service/face_vision_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/live_session_repository_impl.dart';
import 'domain/usecases/reset_tracker.dart';
import 'domain/usecases/start_live_capture.dart';
import 'domain/usecases/start_vision_service.dart';
import 'domain/usecases/stop_live_capture.dart';
import 'domain/usecases/stop_vision_service.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/providers/face_vision_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FaceVisionApp());
}

class FaceVisionApp extends StatelessWidget {
  const FaceVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = FaceVisionServiceClient();
    final liveRepo = LiveSessionRepositoryImpl(
      FaceVisionLiveSession(client: client),
    );

    final startVisionService = StartVisionService(liveRepo);
    final stopVisionService = StopVisionService(liveRepo);
    final startLiveCapture = StartLiveCapture(liveRepo);
    final stopLiveCapture = StopLiveCapture(liveRepo);
    final resetTracker = ResetTracker(liveRepo);

    final provider = FaceVisionProvider(
      startVisionService: startVisionService,
      stopVisionService: stopVisionService,
      startLiveCapture: startLiveCapture,
      stopLiveCapture: stopLiveCapture,
      resetTracker: resetTracker,
      liveSessionRepository: liveRepo,
    );

    return ChangeNotifierProvider<FaceVisionProvider>.value(
      value: provider,
      child: MaterialApp(
        title: 'Face Vision',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
