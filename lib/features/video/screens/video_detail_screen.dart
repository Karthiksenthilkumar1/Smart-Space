import 'dart:convert';
import 'package:flutter/material.dart';
import 'video_player_screen.dart';

class VideoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> video;

  const VideoDetailScreen({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    final measurements =
    video["measurements"] == null
        ? []
        : jsonDecode(
            video["measurements"],
          );
          final thumbnailUrl =
            video["thumbnailUrl"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                ),
                ],
            ),
            child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                const Text(
                    "Video Measurement Session",
                    style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    ),
                ),

                const SizedBox(height: 8),

                Text(
                    video["createdAt"]
                        .toString()
                        .substring(0, 10),
                    style: const TextStyle(
                    color: Colors.grey,
                    ),
                ),

                const SizedBox(height: 8),

                Text(
                    "${measurements.length} Measurement(s)",
                    style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                    ),
                ),
                ],
            ),
            ),

            const SizedBox(height: 10),

            SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle),
                label: const Text("PLAY VIDEO"),
                onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                        videoUrl: video["videoUrl"],
                    ),
                    ),
                );
                },
            ),
            ),

            const SizedBox(height: 20),

            if (thumbnailUrl != null)
                Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.only(
                    bottom: 20,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                    ),
                    ],
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                    children: [
                    ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16),
                    child: Image.network(
                        thumbnailUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                    ),
                    ),

                    Positioned.fill(
                        child: CustomPaint(
                            painter: VideoMeasurementPainter(
                            measurements,
                            ),
                        ),
                    ),
                ],
                ),
                ),
            ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Measurements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount:
                    measurements == null
                        ? 0
                        : measurements.length,
                itemBuilder: (context, index) {
                  final m = measurements[index];

                  return Container(
                margin: const EdgeInsets.only(
                    bottom: 12,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(
                        0.05,
                        ),
                        blurRadius: 8,
                    ),
                    ],
                ),
                child: ListTile(
                    leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(
                        0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.straighten,
                        color: Colors.indigo,
                    ),
                    ),
                    title: Text(
                    m["name"].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                    subtitle: Text(
                    "${(m["distance"] as num).toDouble().toStringAsFixed(1)} cm",
                    ),
                ),
                );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
      ..color = Colors.red
      ..strokeWidth = 3;

    for (var m in measurements) {
      final p1 = Offset(
        (m["point1x"] as num)
            .toDouble(),
        (m["point1y"] as num)
            .toDouble(),
      );

      final p2 = Offset(
        (m["point2x"] as num)
            .toDouble(),
        (m["point2y"] as num)
            .toDouble(),
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