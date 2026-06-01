import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class FramePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String videoPath;

  final List<Map<String, dynamic>>? savedMeasurements;

  const FramePreviewScreen({
    super.key,
    required this.imagePath,
    required this.videoPath,
    this.savedMeasurements,
  });

  @override
  State<FramePreviewScreen> createState() =>
      _FramePreviewScreenState();
}

class _FramePreviewScreenState
    extends State<FramePreviewScreen> {
  Offset? point1;
  Offset? point2;

  final TextEditingController sizeController =
      TextEditingController();

  final TextEditingController measurementNameController =
      TextEditingController();

  double pixelsPerCm = 0;

  Offset? measurePoint1;
  Offset? measurePoint2;

  bool measurementMode = false;

  List<Map<String, dynamic>> measurements = [];

  @override
  void initState() {
    super.initState();

    if (widget.savedMeasurements != null) {
      measurements =
        List<Map<String, dynamic>>.from(
        widget.savedMeasurements!,
      );
    }
   }

  double calculateDistance() {
    if (point1 == null || point2 == null) {
      return 0;
    }

    final dx = point2!.dx - point1!.dx;
    final dy = point2!.dy - point1!.dy;

    return sqrt(dx * dx + dy * dy);
  }

  double calculateMeasuredCm() {
    if (measurePoint1 == null ||
        measurePoint2 == null ||
        pixelsPerCm == 0) {
      return 0;
    }

    final dx =
        measurePoint2!.dx - measurePoint1!.dx;

    final dy =
        measurePoint2!.dy - measurePoint1!.dy;

    final pixelDistance =
        sqrt(dx * dx + dy * dy);

    return pixelDistance / pixelsPerCm;
  }

  void saveMeasurement() {
    if (measurementNameController.text.isEmpty) {
        return;
    }

    measurements.add({
    "name": measurementNameController.text,
    "distance": calculateMeasuredCm(),

    "point1x": measurePoint1!.dx,
    "point1y": measurePoint1!.dy,

    "point2x": measurePoint2!.dx,
    "point2y": measurePoint2!.dy,
    });

    measurementNameController.clear();

    measurePoint1 = null;
    measurePoint2 = null;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
        content: Text("Measurement Saved"),
        ),
    );

    setState(() {});
  }

  Future<void> saveVideoData() async {
    final result =
        await ApiService.saveVideoScan(
        videoPath: widget.videoPath,
        thumbnailUrl: widget.imagePath,
        pixelsPerCm: pixelsPerCm,
        measurements: measurements,
    );

    if (!mounted) return;

    if (result["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
            "Video Uploaded Successfully",
            ),
        ),
        );
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
            result["data"]["message"] ??
                "Upload Failed",
            ),
        ),
        );
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Reference Object"),
      ),
      body: GestureDetector(
        onTapDown: (details) {
          setState(() {
            if (!measurementMode) {
              if (point1 == null) {
                point1 = details.localPosition;
              } else if (point2 == null) {
                point2 = details.localPosition;
              } else {
                point1 = details.localPosition;
                point2 = null;
              }
            } else {
              if (measurePoint1 == null) {
                measurePoint1 = details.localPosition;
              } else if (measurePoint2 == null) {
                measurePoint2 = details.localPosition;
              } else {
                measurePoint1 = details.localPosition;
                measurePoint2 = null;
              }
            }
          });
        },
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),

            CustomPaint(
                size: Size.infinite,
                painter: MeasurementPainter(measurements),
            ),

            // Calibration Point 1
            if (point1 != null)
              Positioned(
                left: point1!.dx - 10,
                top: point1!.dy - 10,
                child: const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 20,
                ),
              ),

            // Calibration Point 2
            if (point2 != null)
              Positioned(
                left: point2!.dx - 10,
                top: point2!.dy - 10,
                child: const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 20,
                ),
              ),

            // Measurement Point 1
            if (measurePoint1 != null)
              Positioned(
                left: measurePoint1!.dx - 14,
                top: measurePoint1!.dy - 14,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.yellow,
                  size: 30,
                ),
              ),

            // Measurement Point 2
            if (measurePoint2 != null)
              Positioned(
                left: measurePoint2!.dx - 14,
                top: measurePoint2!.dy - 14,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 30,
                ),
              ),

              // Saved Measurement Point 1
            ...measurements.map(
            (m) => Positioned(
                left: m["point1x"] - 12,
                top: m["point1y"] - 12,
                child: const Icon(
                Icons.location_on,
                color: Colors.purple,
                size: 26,
                ),
            ),
            ),

            // Saved Measurement Point 2
            ...measurements.map(
            (m) => Positioned(
                left: m["point2x"] - 12,
                top: m["point2y"] - 12,
                child: const Icon(
                Icons.location_on,
                color: Colors.cyan,
                size: 26,
                ),
            ),
            ),

            // Measured Distance Display
            if (measurePoint1 != null &&
                measurePoint2 != null)
              Positioned(
                top: 80,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black87,
                  child: Text(
                    "${calculateMeasuredCm().toStringAsFixed(2)} cm",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            if (point1 != null && point2 != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black87,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Pixels: ${calculateDistance().toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: sizeController,
                        keyboardType:
                            TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration:
                            const InputDecoration(
                          hintText:
                              "Enter actual size in cm",
                          hintStyle: TextStyle(
                            color: Colors.white70,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          final actualCm =
                              double.tryParse(
                                  sizeController.text);

                          if (actualCm == null ||
                              actualCm <= 0) {
                            return;
                          }

                          setState(() {
                            pixelsPerCm =
                                calculateDistance() /
                                    actualCm;
                          });
                        },
                        child:
                            const Text("CALIBRATE"),
                      ),

                      const SizedBox(height: 10),

                      if (pixelsPerCm > 0)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              measurementMode = true;
                              measurePoint1 = null;
                              measurePoint2 = null;
                            });
                          },
                          child: const Text(
                              "MEASURE SPACE"),
                        ),

                      if (measurementMode)
                        Column(
                            children: [
                            const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                "Measurement Mode Active",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                ),
                                ),
                            ),

                            const SizedBox(height: 10),

                            TextField(
                                controller: measurementNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                hintText: "Measurement Name",
                                hintStyle: TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(),
                                ),
                            ),
                            ],
                        ),

                        if (measurementMode &&
                            measurePoint1 != null &&
                            measurePoint2 != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                            onPressed: saveMeasurement,
                            child: const Text("SAVE MEASUREMENT"),
                            ),
                        ),

                      if (pixelsPerCm > 0)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                                  top: 10),
                          child: Text(
                            "1 cm = ${pixelsPerCm.toStringAsFixed(2)} pixels",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        if (measurements.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton.icon(
                                onPressed: saveVideoData,
                                icon: const Icon(Icons.save),
                                label: const Text(
                                    "SAVE VIDEO",
                                ),
                                ),
                            ),

                        if (measurements.isNotEmpty)
                        Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Column(
                            children: measurements.map((m) {
                                return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                ),
                                child: Text(
                                    "${m["name"]} : ${m["distance"].toStringAsFixed(2)} cm",
                                    style: const TextStyle(
                                    color: Colors.white,
                                    ),
                                ),
                                );
                            }).toList(),
                            ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
    }

    class MeasurementPainter extends CustomPainter {
    final List<Map<String, dynamic>> measurements;

    MeasurementPainter(this.measurements);

    @override
    void paint(Canvas canvas, Size size) {
        final paintLine = Paint()
        ..color = Colors.green
        ..strokeWidth = 3;

        for (var m in measurements) {
        final p1 = Offset(
            m["point1x"],
            m["point1y"],
        );

        final p2 = Offset(
            m["point2x"],
            m["point2y"],
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

        final textPainter = TextPainter(
        text: TextSpan(
            text:
                "${m["name"]}\n${m["distance"].toStringAsFixed(1)} cm",
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

        textPainter.paint(
        canvas,
        midpoint,
        );
        }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return true;
    }
}
