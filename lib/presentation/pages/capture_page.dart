import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/face_vision_provider.dart';
import '../widgets/face_overlay_painter.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Vision'),
        actions: [
          Consumer<FaceVisionProvider>(
            builder: (context, provider, _) {
              if (!provider.isServiceRunning) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset session',
                onPressed: provider.isStoppingService
                    ? null
                    : provider.resetSession,
              );
            },
          ),
          Consumer<FaceVisionProvider>(
            builder: (context, provider, _) {
              if (!provider.isServiceRunning &&
                  !provider.isStartingService) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: 'Stop service',
                onPressed: provider.isStoppingService ||
                        provider.isStartingService
                    ? null
                    : provider.stopService,
              );
            },
          ),
        ],
      ),
      body: Consumer<FaceVisionProvider>(
        builder: (context, provider, _) {
          if (provider.isStartingService) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Starting service and camera...'),
                ],
              ),
            );
          }

          if (provider.isStoppingService) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Stopping...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.lastResult == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    if (!provider.isServiceRunning) ...[
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: provider.startService,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start service'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final frame = provider.lastResult;
          if (frame == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLiveScanning) ...[
                      const Text(
                        'Live scanning every 2s',
                        style: TextStyle(color: Colors.green),
                      ),
                      if (provider.isAnalyzing) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Analyzing...'),
                      ],
                    ] else
                      const Text(
                        'Start service to load models and begin live scan.',
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            );
          }

          final imageSize = Size(
            frame.width.toDouble(),
            frame.height.toDouble(),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Live scanning every 2s',
                      style: TextStyle(color: Colors.green),
                    ),
                    if (provider.isAnalyzing) ...[
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      const Text('Analyzing...'),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: imageSize.width / imageSize.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(frame.jpegBytes, fit: BoxFit.fill),
                        CustomPaint(
                          painter: FaceOverlayPainter(frame, imageSize),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<FaceVisionProvider>(
        builder: (context, provider, _) {
          if (provider.isStartingService ||
              provider.isStoppingService ||
              provider.isServiceRunning) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: provider.startService,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start service'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
