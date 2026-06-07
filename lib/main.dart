import 'package:face_vision_service/face_vision_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/model_loader.dart';
import 'data/datasources/opencv_camera_datasource.dart';
import 'data/repositories/camera_repository_impl.dart';
import 'data/repositories/face_analysis_repository_impl.dart';
import 'domain/usecases/analyze_image.dart';
import 'domain/usecases/start_vision_service.dart';
import 'domain/usecases/stop_vision_service.dart';
import 'presentation/pages/capture_page.dart';
import 'presentation/providers/face_vision_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FaceVisionApp());
}

class FaceVisionApp extends StatelessWidget {
  const FaceVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modelLoader = ModelLoader();
    final serviceClient = FaceVisionServiceClient(
      readBytes: modelLoader.readAssetBytes,
    );
    final cameraRepo = CameraRepositoryImpl(OpenCvCameraDatasource());

    final analysisRepo = FaceAnalysisRepositoryImpl(serviceClient);
    final startVisionService = StartVisionService(analysisRepo);
    final stopVisionService = StopVisionService(analysisRepo);
    final analyzeImage = AnalyzeImage(analysisRepo);

    final provider = FaceVisionProvider(
      startVisionService: startVisionService,
      stopVisionService: stopVisionService,
      analyzeImage: analyzeImage,
      camera: cameraRepo,
      analysisRepository: analysisRepo,
    );

    return ChangeNotifierProvider<FaceVisionProvider>.value(
      value: provider,
      child: MaterialApp(
        title: 'Face Vision',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const CapturePage(),
      ),
    );
  }
}
