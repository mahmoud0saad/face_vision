import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/face_snapshot.dart';

class FacePreviewStrip extends StatelessWidget {
  const FacePreviewStrip({super.key, required this.snapshots});

  final List<FaceSnapshot> snapshots;

  static const double _stripHeight = 108;
  static const double _thumbSize = 72;

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return SizedBox(
        height: 40,
        child: Center(
          child: Text(
            'No faces detected',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: _stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: snapshots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final snapshot = snapshots[index];
          return _FaceThumbnail(
            snapshot: snapshot,
            thumbSize: _thumbSize,
          );
        },
      ),
    );
  }
}

class _FaceThumbnail extends StatelessWidget {
  const _FaceThumbnail({
    required this.snapshot,
    required this.thumbSize,
  });

  final FaceSnapshot snapshot;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    final face = snapshot.face;
    final box = face.box;
    final scale = thumbSize / math.max(box.width, box.height);

    return SizedBox(
      width: thumbSize + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: thumbSize,
              height: thumbSize,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -box.x * scale,
                    top: -box.y * scale,
                    child: Image.memory(
                      snapshot.jpegBytes,
                      width: snapshot.frameWidth * scale,
                      height: snapshot.frameHeight * scale,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '#${face.id} ${face.gender.label}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            face.age.label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
