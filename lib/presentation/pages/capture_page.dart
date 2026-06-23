import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/face_vision_provider.dart';
import '../widgets/face_overlay_painter.dart';
import '../widgets/face_preview_strip.dart';

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
              if (!provider.isLiveScanning) return const SizedBox.shrink();
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
              if (!provider.isLiveScanning &&
                  !provider.isStartingCapture &&
                  !provider.isWaitingForFirstFrame) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: 'Stop camera',
                onPressed: provider.isStoppingService ||
                        provider.isStartingCapture
                    ? null
                    : provider.stopCapture,
              );
            },
          ),
        ],
      ),
      body: Consumer<FaceVisionProvider>(
        builder: (context, provider, _) {
          if (provider.isStartingCapture || provider.isWaitingForFirstFrame) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    provider.isStartingCapture
                        ? 'Opening camera...'
                        : 'Capturing first frame...',
                  ),
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
                  ],
                ),
              ),
            );
          }

          final frame = provider.lastResult;
          if (frame == null) {
            final idleMessage = provider.isLiveScanning
                ? 'Live scanning every 2s'
                : 'Start camera to begin live scan.';
            final idleStyle = provider.isLiveScanning
                ? const TextStyle(color: Colors.green)
                : null;

            if (provider.accumulatedFaces.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    idleMessage,
                    style: idleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Column(
              children: [
                FacePreviewStrip(snapshots: provider.accumulatedFaces),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        idleMessage,
                        style: idleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
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
                child: const Text(
                  'Live scanning every 2s',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              FacePreviewStrip(snapshots: provider.accumulatedFaces),
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
          if (provider.isStartingCapture ||
              provider.isStoppingService ||
              provider.isWaitingForFirstFrame ||
              provider.isLiveScanning ||
              !provider.isServiceRunning) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: provider.startCapture,
            icon: const Icon(Icons.videocam),
            label: const Text('Start camera'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
