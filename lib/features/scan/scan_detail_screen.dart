import 'package:flutter/material.dart';

class ScanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scan;

  const ScanDetailScreen({
    super.key,
    required this.scan,
  });

  bool _isValidImageUrl(dynamic url) {
    if (url == null) return false;
    final value = url.toString().trim();
    return value.startsWith("http");
  }

  Color _roomColor(String roomType) {
    switch (roomType) {
      case "Bedroom":
        return Colors.purple;
      case "Kitchen":
        return Colors.orange;
      case "Living Room":
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  List<Map<String, dynamic>> _measurementLines() {
    final lines = scan["measurementLines"];

    if (lines is List) {
      return lines.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    print("SCAN DATA = $scan");
    print("MEASUREMENT LINES = ${scan["measurementLines"]}");
    final width = ((scan["width"] ?? 0) as num).toDouble();

    final height = ((scan["height"] ?? 0) as num).toDouble();

    final depth = ((scan["depth"] ?? 0) as num).toDouble();

    final area = ((scan["area"] ?? 0) as num).toDouble();
    final roomType = scan["roomType"] ?? "Study Room";
    final date = scan["createdAt"].toString().substring(0, 10);
    final measurementLines = _measurementLines();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Scan Details"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  _isValidImageUrl(scan["imageUrl"])
                      ? Image.network(
                          scan["imageUrl"],
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 280,
                          color: Colors.indigo.shade50,
                          child: const Center(
                            child: Icon(
                              Icons.home_work,
                              size: 90,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                  if (measurementLines.isNotEmpty)
                    CustomPaint(
                      size: const Size(
                        double.infinity,
                        double.infinity,
                      ),
                      painter: SavedMeasurementPainter(
                        measurementLines,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _roomColor(roomType).withOpacity(0.12),
                  child: Icon(
                    Icons.auto_awesome,
                    color: _roomColor(roomType),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$roomType Detected",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Saved on $date",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  "Width",
                  "${width.toStringAsFixed(2)} cm",
                ),
              ),
              Expanded(
                child: _metricCard(
                  "Height",
                  "${height.toStringAsFixed(2)} cm",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  "Depth",
                  "${depth.toStringAsFixed(2)} cm",
                ),
              ),
              Expanded(
                child: _metricCard(
                  "Area",
                  "${area.toStringAsFixed(2)} m²",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "This scan was analyzed using the SpaceFit measurement engine and room-aware recommendation logic.",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class SavedMeasurementPainter extends CustomPainter {
  final List<Map<String, dynamic>> lines;

  SavedMeasurementPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 4;

    for (final line in lines) {
      final x1 = (line["point1x"] as num).toDouble();
      final y1 = (line["point1y"] as num).toDouble();
      final x2 = (line["point2x"] as num).toDouble();
      final y2 = (line["point2y"] as num).toDouble();

      final scaleY = size.height / 360;
      final scaleX = size.width / 360;

      final p1 = Offset(
        x1 * scaleX,
        y1 * scaleY,
      );

      final p2 = Offset(
        x2 * scaleX,
        y2 * scaleY,
      );
      canvas.drawLine(p1, p2, linePaint);

      final midpoint = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );

      final dimension = line["dimension"] ?? "Measure";
      final value = (line["value"] as num).toDouble();

      final textPainter = TextPainter(
        text: TextSpan(
          text: "$dimension\n${value.toStringAsFixed(1)} cm",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, midpoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
