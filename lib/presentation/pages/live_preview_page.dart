import 'dart:async';

import 'package:face_vision_service/face_vision_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Real-time camera preview with live face detection rectangles, rendered by
/// the package's [FaceVisionLivePreview] widget.
///
/// This screen drives the shared [FaceVisionLiveSession] with the package's
/// opt-in preview feature (`enablePreview: true`) and stops it on exit.
class LivePreviewPage extends StatefulWidget {
  const LivePreviewPage({super.key});

  @override
  State<LivePreviewPage> createState() => _LivePreviewPageState();
}

class _LivePreviewPageState extends State<LivePreviewPage> {
  static const double _liveIntervalSeconds = 0.5;

  late final FaceVisionLiveSession _session;
  bool _starting = true;
  bool _previewOn = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = context.read<FaceVisionLiveSession>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      // Reuse the shared session; ensure a clean state before starting with
      // the preview feature enabled.
      if (_session.isActive) {
        await _session.stop();
      }
      await _session.start(
        intervalSeconds: _liveIntervalSeconds,
        enablePreview: true,
      );
      _previewOn = _session.previewEnabled;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }

  void _togglePreview() {
    setState(() {
      _previewOn = !_previewOn;
      _session.setPreviewEnabled(_previewOn);
    });
  }

  @override
  void dispose() {
    unawaited(_session.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Preview'),
        actions: [
          if (!_starting && _error == null)
            IconButton(
              icon: Icon(_previewOn ? Icons.videocam : Icons.videocam_off),
              tooltip: _previewOn ? 'Disable preview' : 'Enable preview',
              onPressed: _togglePreview,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_starting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting camera...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_previewOn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              'Preview disabled\nFace analysis is still running.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: FaceVisionLivePreview(
        session: _session,
        showLabels: true,
        boxColor: Colors.greenAccent,
        fit: BoxFit.contain,
      ),
    );
  }
}
