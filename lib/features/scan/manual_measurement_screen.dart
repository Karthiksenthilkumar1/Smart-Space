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
  List<Map<String, dynamic>> savedLines = [];
  int? selectedPointIndex;

  double? calculatedLength;

  double? manualWidth;
  double? manualHeight;
  double? manualDepth;
  Map<String, double>? completedObject;

  String selectedDimension = "Width";

  double _distance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  void _calculateMeasurement() {
    if (points.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select 2 reference points and 2 target points"),
        ),
      );
      return;
    }

    final referenceCm = double.tryParse(referenceController.text.trim()) ?? 0;

    if (referenceCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter reference size in cm"),
        ),
      );
      return;
    }

    final referencePixels = _distance(points[0], points[1]);
    final targetPixels = _distance(points[2], points[3]);

    final cmPerPixel = referenceCm / referencePixels;

    setState(() {
      calculatedLength = targetPixels * cmPerPixel;
    });
  }

  void _saveSide() {
    if (calculatedLength == null) return;

    final length = calculatedLength!;

    setState(() {
      savedLines.add({
        "dimension": selectedDimension,
        "point1": points[2],
        "point2": points[3],
        "value": length,
      });

      if (selectedDimension == "Width") {
        manualWidth = length;
      } else if (selectedDimension == "Height") {
        manualHeight = length;
      } else if (selectedDimension == "Depth") {
        manualDepth = length;
      }

      completedObject = null;
      calculatedLength = null;

      if (points.length == 4) {
        points.removeRange(2, 4);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$selectedDimension saved"),
      ),
    );
  }

  Map<String, double>? _calculateObject3D() {
    if (manualWidth == null && manualHeight == null && manualDepth == null) {
      return null;
    }

    double width = manualWidth ?? 0;
    double height = manualHeight ?? 0;
    double depth = manualDepth ?? 0;

    if (manualWidth != null) {
      width = manualWidth!;
      height = manualHeight ?? width * 0.7;
      depth = manualDepth ?? width * 0.5;
    } else if (manualHeight != null) {
      height = manualHeight!;
      width = manualWidth ?? height / 0.7;
      depth = manualDepth ?? width * 0.5;
    } else if (manualDepth != null) {
      depth = manualDepth!;
      width = manualWidth ?? depth / 0.5;
      height = manualHeight ?? width * 0.7;
    }

    return {
      "width": width,
      "height": height,
      "depth": depth,
      "area": (width * depth) / 10000,
    };
  }

  void _completeObject() {
    final object = _calculateObject3D();

    if (object == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Measure at least one side first"),
        ),
      );
      return;
    }

    setState(() {
      completedObject = object;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Object completed"),
      ),
    );
  }

  void _resetPoints() {
    setState(() {
      points.clear();
      savedLines.clear();
      calculatedLength = null;
      manualWidth = null;
      manualHeight = null;
      manualDepth = null;
      completedObject = null;
      selectedPointIndex = null;
    });
  }

  void _undoLastPoint() {
    if (points.isEmpty) return;

    setState(() {
      points.removeLast();
      calculatedLength = null;
    });
  }

  @override
  void dispose() {
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final object3D = completedObject;

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
            "Tap 2 points for reference object, then 2 points for the selected dimension.",
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: referenceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Known reference size in cm, e.g. 80",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDimension,
            decoration: InputDecoration(
              labelText: "Select Dimension",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Width", child: Text("Width")),
              DropdownMenuItem(value: "Height", child: Text("Height")),
              DropdownMenuItem(value: "Depth", child: Text("Depth")),
            ],
            onChanged: (value) {
              setState(() {
                selectedDimension = value!;
                calculatedLength = null;
                if (points.length == 4) {
                  points.removeRange(2, 4);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTapDown: (details) {
              final tap = details.localPosition;

              for (int i = 0; i < points.length; i++) {
                if ((points[i] - tap).distance < 25) {
                  selectedPointIndex = i;
                  return;
                }
              }

              if (points.length < 4) {
                setState(() {
                  points.add(tap);
                  calculatedLength = null;
                });
              }
            },
            onPanUpdate: (details) {
              if (selectedPointIndex == null) return;

              setState(() {
                points[selectedPointIndex!] += details.delta;
                calculatedLength = null;
              });
            },
            onPanEnd: (_) {
              selectedPointIndex = null;
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
                        size: const Size(
                          double.infinity,
                          double.infinity,
                        ),
                        painter: MeasurementPainter(points, savedLines),
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
          const SizedBox(height: 12),
          if (manualWidth != null ||
              manualHeight != null ||
              manualDepth != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Saved Dimensions\n"
                "Width: ${manualWidth?.toStringAsFixed(1) ?? "-"} cm\n"
                "Height: ${manualHeight?.toStringAsFixed(1) ?? "-"} cm\n"
                "Depth: ${manualDepth?.toStringAsFixed(1) ?? "-"} cm",
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 18),
          if (calculatedLength != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "$selectedDimension: ${calculatedLength!.toStringAsFixed(1)} cm",
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
          const SizedBox(height: 12),
          if (calculatedLength != null)
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveSide,
                icon: const Icon(Icons.save),
                label: const Text("SAVE SIDE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (manualWidth != null ||
              manualHeight != null ||
              manualDepth != null)
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _completeObject,
                icon: const Icon(Icons.check_circle),
                label: const Text("COMPLETE OBJECT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          const SizedBox(height: 18),
          if (object3D != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    "Final Estimated Object",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Width: ${object3D["width"]!.toStringAsFixed(1)} cm\n"
                    "Height: ${object3D["height"]!.toStringAsFixed(1)} cm\n"
                    "Depth: ${object3D["depth"]!.toStringAsFixed(1)} cm\n"
                    "Area: ${object3D["area"]!.toStringAsFixed(2)} m²",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          if (object3D != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final response = await ApiService.saveScan(
                        imagePath: widget.imagePath,
                        width: object3D["width"]!,
                        height: object3D["height"]!,
                        depth: object3D["depth"]!,
                        area: object3D["area"]!,
                        roomType: "Manual Measurement",
                        measurementLines: savedLines.map((line) {
                          final p1 = line["point1"] as Offset;
                          final p2 = line["point2"] as Offset;

                          return {
                            "dimension": line["dimension"],
                            "value": line["value"],
                            "point1x": p1.dx,
                            "point1y": p1.dy,
                            "point2x": p2.dx,
                            "point2y": p2.dy,
                          };
                        }).toList(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response["data"]["message"] ??
                                "Manual measurement saved",
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
                            width: object3D["width"]!,
                            height: object3D["height"]!,
                            depth: object3D["depth"]!,
                            area: object3D["area"]!,
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
  final List<Map<String, dynamic>> savedLines;

  MeasurementPainter(this.points, this.savedLines);

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

    final savedLinePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3;

    for (final line in savedLines) {
      final p1 = line["point1"] as Offset;
      final p2 = line["point2"] as Offset;
      final dimension = line["dimension"];
      final value = line["value"] as double;

      canvas.drawLine(p1, p2, savedLinePaint);

      final midpoint = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );

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
