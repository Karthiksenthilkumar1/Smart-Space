import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

class FrameViewScreen extends StatefulWidget {
  final Map measurement;
  final String videoUrl;

  const FrameViewScreen({
    super.key,
    required this.measurement,
    required this.videoUrl,
  });

  @override
  State<FrameViewScreen> createState() =>
      _FrameViewScreenState();
}

class _FrameViewScreenState
    extends State<FrameViewScreen> {

  String? framePath;

  @override
  void initState() {
    super.initState();
    loadFrame();
  }

  Future<void> loadFrame() async {

    final path =
        await vt.VideoThumbnail.thumbnailFile(
      video: widget.videoUrl,
      imageFormat: vt.ImageFormat.PNG,
      quality: 100,
      timeMs:
          widget.measurement["frameTimeMs"],
    );

    print("Generated Frame: $path");

    setState(() {
      framePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Frame",
        ),
      ),
      body: Center(
        child: framePath == null
            ? const CircularProgressIndicator()
            : Stack(
          children: [

            Image.file(
              File(framePath!),
              width: double.infinity,
              fit: BoxFit.contain,
            ),

            Positioned.fill(
              child: CustomPaint(
                painter: FrameMeasurementPainter(
                  widget.measurement,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
  
}
class FrameMeasurementPainter
    extends CustomPainter {

  final Map measurement;

  FrameMeasurementPainter(
    this.measurement,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final p1 = Offset(
      (measurement["point1x"] as num)
          .toDouble(),
      (measurement["point1y"] as num)
          .toDouble(),
    );

    final p2 = Offset(
      (measurement["point2x"] as num)
          .toDouble(),
      (measurement["point2y"] as num)
          .toDouble(),
    );

    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    canvas.drawLine(
      p1,
      p2,
      linePaint,
    );

    canvas.drawCircle(
      p1,
      8,
      Paint()..color = Colors.red,
    );

    canvas.drawCircle(
      p2,
      8,
      Paint()..color = Colors.red,
    );
    final midpoint = Offset(
  (p1.dx + p2.dx) / 2,
  (p1.dy + p2.dy) / 2,
);

final textPainter = TextPainter(
  text: TextSpan(
    text:
        "${measurement["name"]}\n${(measurement["distance"] as num).toDouble().toStringAsFixed(1)} cm",
    style: const TextStyle(
      color: Colors.white,
      backgroundColor: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
  textDirection: TextDirection.ltr,
);

textPainter.layout();

textPainter.paint(
  canvas,
  midpoint,
);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return true;
  }
}