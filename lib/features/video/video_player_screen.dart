import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  final List<Map<String, dynamic>> measurements;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.measurements,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  double playbackSpeed = 1.0;

  List<Map<String, dynamic>> activeMeasurements = [];

  @override
  void initState() {
    debugPrint(
      "TOTAL MEASUREMENTS: ${widget.measurements.length}",
    );

for (var m in widget.measurements) {
  print("AAAAAAAAAAAAA $m");

  debugPrint(
    "MEASUREMENT => ${m["name"]} | frameTimeMs=${m["frameTimeMs"]}",
  );

}
    super.initState();

    controller = VideoPlayerController.file(
      File(widget.videoPath),
    )
      ..initialize().then((_) {
        setState(() {});
      });

    controller.addListener(() {

      final currentTime =
          controller.value.position.inMilliseconds;

      final visibleMeasurements =
          widget.measurements.where((m) {

        final frameTime =
            m["frameTimeMs"] ?? 0;

        return (currentTime - frameTime).abs() < 1000;

      }).toList();

      if (mounted) {
        setState(() {
          activeMeasurements =
              List<Map<String, dynamic>>.from(
            visibleMeasurements,
          );
          debugPrint(
            "TIME: $currentTime | ACTIVE: ${activeMeasurements.length}",
          );
          for (var m in activeMeasurements) {
            debugPrint(
              "SHOWING: ${m["name"]} @ ${m["frameTimeMs"]}",
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recorded Video"),
      ),
      
      body: Column(
        children: [

          Expanded(
            child: Center(
              child: controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio:
                          controller.value.aspectRatio,
                      child: Stack(
                        children: [

                          VideoPlayer(controller),

                          Positioned.fill(
                            child: CustomPaint(
                              painter:
                                  ReplayMeasurementPainter(
                                activeMeasurements,
                              ),
                            ),
                          ),

                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),

          const SizedBox(height: 10),

          Container(
  color: Colors.yellow,
  child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              ElevatedButton(
                onPressed: () async {
                  await controller.setPlaybackSpeed(
                    0.25,
                  );

                  setState(() {
                    playbackSpeed = 0.25;
                  });
                },
                child: const Text("0.25x"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () async {
                  await controller.setPlaybackSpeed(
                    0.5,
                  );

                  setState(() {
                    playbackSpeed = 0.5;
                  });
                },
                child: const Text("0.5x"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () async {
                  await controller.setPlaybackSpeed(
                    1.0,
                  );

                  setState(() {
                    playbackSpeed = 1.0;
                  });
                },
                child: const Text("1x"),
              ),
            ],
          ),
          ),

          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            controller.value.isPlaying
                ? controller.pause()
                : controller.play();
          });
        },
        child: Icon(
          controller.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}

class ReplayMeasurementPainter extends CustomPainter {
  final List<Map<String, dynamic>> measurements;

  ReplayMeasurementPainter(this.measurements);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    final aiBoxPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.orange;

    for (var m in measurements) {
      print("PAINTING TYPE = ${m["measurementType"]}");

      if (m["measurementType"] == "AI" &&
          m["aiX"] != null &&
          m["aiY"] != null &&
          m["aiWidth"] != null &&
          m["aiHeight"] != null) {
        const originalWidth = 720.0;
        const originalHeight = 1280.0;

        final scaleX = size.width / originalWidth;
        final scaleY = size.height / originalHeight;

        final rect = Rect.fromLTWH(
          (m["aiX"] as num).toDouble() * scaleX,
          (m["aiY"] as num).toDouble() * scaleY,
          (m["aiWidth"] as num).toDouble() * scaleX,
          (m["aiHeight"] as num).toDouble() * scaleY,
        );

        print("DRAWING AI RECT");
        print("RECT = $rect");
        print("CANVAS SIZE = $size");

        canvas.drawRect(rect, aiBoxPaint);

        final textPainter = TextPainter(
          text: TextSpan(
            text: "${m["name"]}\n${(m["distance"] as num).toStringAsFixed(1)} cm",
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
          Offset(rect.left, rect.top - 28),
        );

        continue;
      }

      final p1 = Offset(
        (m["point1x"] as num).toDouble(),
        (m["point1y"] as num).toDouble(),
      );

      final p2 = Offset(
        (m["point2x"] as num).toDouble(),
        (m["point2y"] as num).toDouble(),
      );

      canvas.drawLine(p1, p2, linePaint);
      canvas.drawCircle(p1, 6, pointPaint);
      canvas.drawCircle(p2, 6, pointPaint);

      final midpoint = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${m["name"]}\n${(m["distance"] as num).toStringAsFixed(1)} cm",
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
      textPainter.paint(canvas, midpoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}