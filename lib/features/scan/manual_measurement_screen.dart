import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'suggestions_screen.dart';
import 'package:smart_space/core/services/api_service.dart';

class ManualMeasurementScreen extends StatefulWidget {
  final String imagePath;

  const ManualMeasurementScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ManualMeasurementScreen> createState() =>
      _ManualMeasurementScreenState();
}

class _ManualMeasurementScreenState extends State<ManualMeasurementScreen> {
  final TextEditingController referenceController = TextEditingController();

  List<Offset> points = [];
  double? calculatedWidth;

  double _distance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  void _calculateMeasurement() {
    if (points.length < 4) return;

    final referenceCm = double.tryParse(referenceController.text.trim()) ?? 0;

    if (referenceCm <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
        content: Text("Please enter reference width in cm"),
        ),
    );
    return;
    }

    final referencePixels = _distance(points[0], points[1]);
    final targetPixels = _distance(points[2], points[3]);

    final cmPerPixel = referenceCm / referencePixels;

    setState(() {
      calculatedWidth = targetPixels * cmPerPixel;
    });
  }

  void _resetPoints() {
    setState(() {
      points.clear();
      calculatedWidth = null;
    });
  }

  void _undoLastPoint() {
    if (points.isEmpty) return;

    setState(() {
        points.removeLast();

        calculatedWidth = null;
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Manual Measurement"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Tap 2 points for reference object, then 2 points for target space.",
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: referenceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Known reference width in cm, e.g. 80",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTapDown: (details) {
                if (points.length >= 4) return;

                setState(() {
                points.add(details.localPosition);
                });
            },

            onPanUpdate: (details) {
                if (points.isEmpty) return;

                setState(() {
                points[points.length - 1] += details.delta;
                calculatedWidth = null;
                });
            },
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Stack(
                    children: [
                        Image.file(
                        File(widget.imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        ),

                        CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: MeasurementPainter(points),
                        ),
                    ],
                    ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Selected points: ${points.length}/4",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 18),

          if (calculatedWidth != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "Estimated target width: ${calculatedWidth!.toStringAsFixed(1)} cm",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

          const SizedBox(height: 18),

          Row(
            children: [
                Expanded(
                child: OutlinedButton(
                    onPressed: _undoLastPoint,
                    child: const Text("Undo"),
                ),
                ),
                const SizedBox(width: 8),
                Expanded(
                child: OutlinedButton(
                    onPressed: _resetPoints,
                    child: const Text("Reset"),
                ),
                ),
                const SizedBox(width: 8),
                Expanded(
                child: ElevatedButton(
                    onPressed: _calculateMeasurement,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    ),
                    child: const Text("Calculate"),
                ),
                ),
            ],
            ),

            const SizedBox(height: 18),

            if (calculatedWidth != null)
            Row(
                children: [
                Expanded(
                    child: OutlinedButton(
                    onPressed: () async {
                        if (calculatedWidth == null) return;

                        final manualWidth = calculatedWidth!;
                        final manualHeight = calculatedWidth! * 0.7;
                        final manualDepth = calculatedWidth! * 0.5;
                        final manualArea = (manualWidth * manualHeight) / 10000;

                        final response = await ApiService.saveScan(
                            imagePath: widget.imagePath,
                            width: manualWidth,
                            height: manualHeight,
                            depth: manualDepth,
                            area: manualArea,
                            roomType: "Manual Measurement",
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                            content: Text(
                                response["data"]["message"] ?? "Manual measurement saved",
                            ),
                            ),
                        );
                        },
                    child: const Text("Save Result"),
                    ),
                ),

                const SizedBox(width: 12),

                Expanded(
                    child: ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SuggestionsScreen(
                            width: calculatedWidth!,
                            height: calculatedWidth! * 0.7,
                            depth: calculatedWidth! * 0.5,
                            area: (calculatedWidth! *
                                    (calculatedWidth! * 0.7)) /
                                10000,
                            roomType: "Custom Space",
                            ),
                        ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                    ),
                    child: const Text("Suggestions"),
                    ),
                ),
                ],
            ), 
        ],
      ),
    );
  }
}

class MeasurementPainter extends CustomPainter {
  final List<Offset> points;

  MeasurementPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final referencePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    final targetPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    for (int i = 0; i < points.length; i++) {
    final point = points[i];

    canvas.drawCircle(point, 7, pointPaint);

    final textPainter = TextPainter(
        text: TextSpan(
        text: "${i + 1}",
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
        ),
        ),
        textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
        canvas,
        Offset(point.dx - 5, point.dy - 22),
    );
    }

    if (points.length >= 2) {
      canvas.drawLine(points[0], points[1], referencePaint);
    }

    if (points.length >= 4) {
      canvas.drawLine(points[2], points[3], targetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}