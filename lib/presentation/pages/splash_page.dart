import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/face_vision_provider.dart';
import 'capture_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final provider = context.read<FaceVisionProvider>();
    await provider.bootstrapVision();
    if (!mounted) return;

    if (provider.isServiceRunning) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const CapturePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FaceVisionProvider>(
        builder: (context, provider, _) {
          if (provider.isBootstrapping) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading models…'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
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
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _bootstrap,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading models…'),
              ],
            ),
          );
        },
      ),
    );
  }
}
