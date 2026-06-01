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
          print(video["thumbnailUrl"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.videocam,
                  color: Colors.indigo,
                ),
                title: const Text("Video Scan"),
                subtitle: Text(
                  video["createdAt"]
                      .toString()
                      .substring(0, 10),
                ),
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

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.straighten,
                      ),
                      title: Text(
                        m["name"].toString(),
                      ),
                      subtitle: Text(
                        "${m["distance"]} cm",
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