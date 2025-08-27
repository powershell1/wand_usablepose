import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as dm;

/// Order must match your Python LANDMARK_ORDER.
const List<PoseLandmarkType> _order = [
  PoseLandmarkType.rightWrist,
  PoseLandmarkType.leftWrist,
  PoseLandmarkType.rightElbow,
  PoseLandmarkType.leftElbow,
  PoseLandmarkType.rightShoulder,
  PoseLandmarkType.leftShoulder,
  PoseLandmarkType.rightHip,
  PoseLandmarkType.leftHip,
];

// Indices for orientation frame construction.
final int _idxRS = _order.indexOf(PoseLandmarkType.rightShoulder);
final int _idxLS = _order.indexOf(PoseLandmarkType.leftShoulder);
final int _idxRH = _order.indexOf(PoseLandmarkType.rightHip);
final int _idxLH = _order.indexOf(PoseLandmarkType.leftHip);

typedef Vec3 = List<double>; // [x, y, z]

// Public entry: extract -> orientation -> min-max. Returns N x 3.
List<Vec3> computeNormalizedCoords(
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    ) {
  final base = _extractOrdered(landmarks);       // N x 3
  final oriented = _orientationNormalize(base);  // N x 3 (local frame)
  return _minmaxNormalize(oriented);             // N x 3 in [0,1]
}

/// Build N x 3 array in fixed order.
List<Vec3> _extractOrdered(Map<PoseLandmarkType, PoseLandmark> lm) {
  final out = List<Vec3>.generate(_order.length, (_) => [0.0, 0.0, 0.0],
      growable: false);
  for (var i = 0; i < _order.length; i++) {
    final p = lm[_order[i]];
    if (p == null) continue; // leave zeros if missing
    out[i][0] = p.x;
    out[i][1] = p.y;
    out[i][2] = p.z;
  }
  return out;
}

/// Orientation + scale normalize to a local body frame.
/// Matches Python logic: see _orientation_normalize in your extract.py
List<Vec3> _orientationNormalize(List<Vec3> coords) {
  if (coords.isEmpty) return coords;

  final rs = coords[_idxRS];
  final ls = coords[_idxLS];
  final rh = coords[_idxRH];
  final lh = coords[_idxLH];

  final midShoulders = _scale(_add(rs, ls), 0.5);
  final midHips = _scale(_add(rh, lh), 0.5);
  final origin = midHips;

  var L = _sub(rs, ls);
  var U = _sub(midShoulders, midHips);

  final normL = _norm(L);
  final normU = _norm(U);
  if (normL < 1e-6 || normU < 1e-6) {
    // Degenerate: return zeros
    return List<Vec3>.generate(coords.length, (_) => [0.0, 0.0, 0.0],
        growable: false);
  }
  L = _scale(L, 1.0 / normL);
  U = _scale(U, 1.0 / normU);

  var F = _cross(L, U);
  final normF = _norm(F);
  if (normF < 1e-6) {
    return List<Vec3>.generate(coords.length, (_) => [0.0, 0.0, 0.0],
        growable: false);
  }
  F = _scale(F, 1.0 / normF);

  // Re-orthogonalize U
  U = _cross(F, L);
  final normU2 = _norm(U);
  if (normU2 < 1e-6) {
    return List<Vec3>.generate(coords.length, (_) => [0.0, 0.0, 0.0],
        growable: false);
  }
  U = _scale(U, 1.0 / normU2);

  // Scale by torso size
  var torsoSize = _norm(_sub(midShoulders, midHips));
  if (torsoSize < 1e-6) torsoSize = 1.0;

  // Project into local basis (columns: L, U, F) and scale
  final result = <Vec3>[];
  for (final p in coords) {
    final v = _sub(p, origin);
    final x = _dot(v, L);
    final y = _dot(v, U);
    final z = _dot(v, F);
    result.add([x / torsoSize, y / torsoSize, z / torsoSize]);
  }
  return result;
}

/// Per-axis min-max to [0,1] with safe divide.
List<Vec3> _minmaxNormalize(List<Vec3> coords) {
  if (coords.isEmpty) return coords;

  // Initialize mins/maxs from first.
  var minX = coords[0][0], minY = coords[0][1], minZ = coords[0][2];
  var maxX = coords[0][0], maxY = coords[0][1], maxZ = coords[0][2];

  for (var i = 1; i < coords.length; i++) {
    final p = coords[i];
    if (p[0] < minX) minX = p[0];
    if (p[1] < minY) minY = p[1];
    if (p[2] < minZ) minZ = p[2];
    if (p[0] > maxX) maxX = p[0];
    if (p[1] > maxY) maxY = p[1];
    if (p[2] > maxZ) maxZ = p[2];
  }

  var rangeX = maxX - minX;
  var rangeY = maxY - minY;
  var rangeZ = maxZ - minZ;
  if (rangeX == 0) rangeX = 1.0;
  if (rangeY == 0) rangeY = 1.0;
  if (rangeZ == 0) rangeZ = 1.0;

  return coords
      .map((p) => [
    (p[0] - minX) / rangeX,
    (p[1] - minY) / rangeY,
    (p[2] - minZ) / rangeZ,
  ])
      .toList(growable: false);
}

/* ---------- small Vec3 helpers ---------- */

Vec3 _add(Vec3 a, Vec3 b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
Vec3 _sub(Vec3 a, Vec3 b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
Vec3 _scale(Vec3 a, double s) => [a[0] * s, a[1] * s, a[2] * s];
Vec3 _cross(Vec3 a, Vec3 b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
double _dot(Vec3 a, Vec3 b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
double _norm(Vec3 a) => (a[0] * a[0] + a[1] * a[1] + a[2] * a[2]).sqrt();

extension on double {
  double sqrt() => Math.sqrt(this);
}

// Minimal Math to avoid extra imports; alternatively use dart:math.
class Math {
  static double sqrt(double v) => v <= 0 ? 0.0 : v.toDouble().sqrtNative();
}

// Use native sqrt via dart:math if you prefer:
extension _NativeSqrt on double {
  double sqrtNative() => dm.sqrt(this);
}