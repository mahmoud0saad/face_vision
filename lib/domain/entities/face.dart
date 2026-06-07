import 'age_range.dart';
import 'eye_state.dart';
import 'face_box.dart';
import 'gender.dart';

class Face {
  const Face({
    required this.id,
    required this.box,
    required this.gender,
    required this.age,
    required this.detectionScore,
    required this.leftEye,
    required this.rightEye,
  });

  /// Stable within a tracking session; changes only when the face disappears.
  final int id;
  final FaceBox box;
  final Gender gender;
  final AgeRange age;
  final double detectionScore;
  final EyeState leftEye;
  final EyeState rightEye;
}
