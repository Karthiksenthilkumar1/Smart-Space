import 'package:flutter/material.dart';

class VideoMeasurementPainter
    extends CustomPainter {
  final List measurements;

  VideoMeasurementPainter(
    this.measurements,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paintLine = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    for (var m in measurements) {
      if (m["point1x"] == null ||
          m["point1y"] == null ||
          m["point2x"] == null ||
          m["point2y"] == null) {
        continue;
      }
      final p1 = Offset(
        (m["point1x"] as num)
            .toDouble() + 20,
        (m["point1y"] as num)
            .toDouble() + 40,
      );

      final p2 = Offset(
        (m["point2x"] as num)
            .toDouble() + 20,
        (m["point2y"] as num)
            .toDouble() + 40,
      );

      canvas.drawLine(
        p1,
        p2,
        paintLine,
      );

      final pointPaint = Paint()
        ..color = Colors.red;

        canvas.drawCircle(
        p1,
        6,
        pointPaint,
        );

        canvas.drawCircle(
        p2,
        6,
        pointPaint,
     );

      final midpoint = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );

      final textPainter =
          TextPainter(
        text: TextSpan(
          text:
              "${m["name"]}\n${m["distance"].toStringAsFixed(1)} cm",
          style:
              const TextStyle(
            color: Colors.white,
            backgroundColor:
                Colors.black,
            fontSize: 12,
          ),
        ),
        textDirection:
            TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        midpoint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return true;
  }
}