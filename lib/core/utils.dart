// Custom Clipper for the top-right green shape
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This path is defined for an LTR context
    // but will be flipped automatically by Flutter's RTL handling.
    final Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.9,
      size.width * 0.3,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.0,
      size.height * 0.6,
      0,
      size.height * 0.2,
    );
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class GradeHelper {
  static Grade fromString(String? gradeString) {
    // Basic implementation, assumes gradeString matches enum name
    if (gradeString == null) return Grade.grade9; // Default or error handling
    try {
      return Grade.values.firstWhere((e) => e.name == gradeString);
    } catch (e) {
      log("Error parsing grade: $gradeString. Defaulting to grade9.");
      return Grade.grade9; // Fallback
    }
  }
}
