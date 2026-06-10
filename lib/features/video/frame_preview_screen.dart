import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'video_measurement_result_screen.dart';

class FramePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String videoPath;

  final List<Map<String, dynamic>>? savedMeasurements;

  final int frameTimeMs;

  const FramePreviewScreen({
    super.key,
    required this.imagePath,
    required this.videoPath,
    this.savedMeasurements,
    required this.frameTimeMs,
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
  bool isCalibrated = false;
  bool readyToSave = false;
  bool showMethodSelection = true;
  String selectedDimension = "Width";

  double? objectWidth;
  double? objectHeight;
  double? objectDepth;

  double aiX = 0;
  double aiY = 0;
  double aiWidth = 0;
  double aiHeight = 0;

  double imageWidth = 736;
  double imageHeight = 736;

  final GlobalKey imageKey = GlobalKey();

  List<Map<String, dynamic>> measurements = [];
  List<Map<String, dynamic>> currentFrameMeasurements = [];

  @override
  void initState() {
    super.initState();

    if (widget.savedMeasurements != null) {
      measurements =
        List<Map<String, dynamic>>.from(
        widget.savedMeasurements!,
      );
    }
    loadAIDetection();
   }

   Future<void> loadAIDetection() async {

    final aiResponse =
        await ApiService.detectSpaceWithAI(
      imagePath: widget.imagePath,
    );

    print("VIDEO AI RESPONSE = $aiResponse");

    if (aiResponse["statusCode"] != 200) {
      return;
    }

    final aiData =
        aiResponse["data"]["ai"];

    final detectedSpace =
        aiData["detectedSpace"];

    final imageSize =
        aiData["imageSize"];

    print("RAW IMAGE SIZE = $imageSize");

    setState(() {

      final detectedX = detectedSpace["x"].toDouble();
      final detectedY = detectedSpace["y"].toDouble();
      final detectedWidth = detectedSpace["width"].toDouble();
      final detectedHeight = detectedSpace["height"].toDouble();

      final actualImageWidth = imageSize["width"].toDouble();
      final actualImageHeight = imageSize["height"].toDouble();

      final isFullImageDetection =
          detectedX == 0 &&
          detectedY == 0 &&
          detectedWidth == actualImageWidth &&
          detectedHeight == actualImageHeight;

      if (isFullImageDetection) {
        aiX = actualImageWidth * 0.15;
        aiY = actualImageHeight * 0.25;
        aiWidth = actualImageWidth * 0.70;
        aiHeight = actualImageHeight * 0.45;
      } else {
        aiX = detectedX;
        aiY = detectedY;
        aiWidth = detectedWidth;
        aiHeight = detectedHeight;
      }

      print(
        "AI RECT -> X:$aiX Y:$aiY W:$aiWidth H:$aiHeight",
      );
      print(
        "IMAGE SIZE -> W:$imageWidth H:$imageHeight",
      );

      imageWidth =
          imageSize["width"].toDouble();

      imageHeight =
          imageSize["height"].toDouble();

      print(
        "UPDATED IMAGE SIZE -> W:$imageWidth H:$imageHeight",
      );
    });
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
    if (measurePoint1 == null || measurePoint2 == null) {
      return;
    }

    final measuredCm = calculateMeasuredCm();

    if (selectedDimension == "Width") {
      objectWidth = measuredCm;
    } else if (selectedDimension == "Height") {
      objectHeight = measuredCm;
    } else if (selectedDimension == "Depth") {
      objectDepth = measuredCm;
    }

    currentFrameMeasurements.add({
      "name": selectedDimension,
      "dimensionType": selectedDimension,
      "distance": measuredCm,
      "frameTimeMs": widget.frameTimeMs,
      "frameImage": widget.imagePath,
      "point1x": measurePoint1!.dx,
      "point1y": measurePoint1!.dy,
      "point2x": measurePoint2!.dx,
      "point2y": measurePoint2!.dy,
    });

    measurePoint1 = null;
    measurePoint2 = null;
    readyToSave = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$selectedDimension saved")),
    );

    setState(() {});
  }

  Map<String, double>? calculateObject3D() {
    if (objectWidth == null &&
        objectHeight == null &&
        objectDepth == null) {
      return null;
    }

    double width = objectWidth ?? 0;
    double height = objectHeight ?? 0;
    double depth = objectDepth ?? 0;

    if (objectWidth != null) {
      width = objectWidth!;
      height = objectHeight ?? width * 1.5;
      depth = objectDepth ?? width * 0.6;
    } else if (objectHeight != null) {
      height = objectHeight!;
      width = objectWidth ?? height / 1.5;
      depth = objectDepth ?? width * 0.6;
    } else if (objectDepth != null) {
      depth = objectDepth!;
      width = objectWidth ?? depth / 0.6;
      height = objectHeight ?? width * 1.5;
    }

    return {
      "width": width,
      "height": height,
      "depth": depth,
      "area": (width * depth),
    };
  }

  Future<void> saveVideoData() async {
    final finalObject = calculateObject3D();

    if (finalObject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Measure at least one dimension"),
        ),
      );
      return;
    }

    final objectMeasurement = {
      "name": "Measured Object",
      "measurementType": "OBJECT_3D",
      "width": finalObject["width"],
      "height": finalObject["height"],
      "depth": finalObject["depth"],
      "area": finalObject["area"],
      "volume": finalObject["volume"],
      "frameTimeMs": widget.frameTimeMs,
      "frameImage": widget.imagePath,
    };

    final result = await ApiService.saveVideoScan(
      videoPath: widget.videoPath,
      thumbnailUrl: widget.imagePath,
      pixelsPerCm: pixelsPerCm,
      measurements: [
        objectMeasurement,
        ...currentFrameMeasurements,
      ],
    );

    print(result);

    if (!mounted) return;

    if (result["statusCode"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Video Uploaded Successfully"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["data"]["message"] ?? "Upload Failed",
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
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
        onTapDown: (details) {

          final RenderBox? imageBox =
            imageKey.currentContext?.findRenderObject()
                as RenderBox?;

        if (imageBox == null) return;

        final imagePosition =
            imageBox.localToGlobal(Offset.zero);

        final imageSize = imageBox.size;

        print(
          "DISPLAYED IMAGE SIZE -> "
          "${imageSize.width} x ${imageSize.height}",
        );

        final tapPosition = details.globalPosition;

        if (tapPosition.dx < imagePosition.dx ||
            tapPosition.dx >
                imagePosition.dx + imageSize.width ||
            tapPosition.dy < imagePosition.dy ||
            tapPosition.dy >
                imagePosition.dy + imageSize.height) {
        return;
        }  
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
        child: 
            Padding(
            padding: const EdgeInsets.only(
                bottom: 180,
            ),
            child: Center(
                child: Container(
                key: imageKey,
                child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                ),
                ),
            ),
            ),
          ),


            if (aiWidth > 0 && aiHeight > 0)
            Positioned(
              left: aiX * 280 / imageWidth,
              top: aiY * 500 / imageHeight,
              child: IgnorePointer(
                child: Container(
                  width: aiWidth * 280 / imageWidth,
                  height: aiHeight * 500 / imageHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
                                

            IgnorePointer( child: CustomPaint(
              size: Size.infinite,
              painter: MeasurementPainter(
                currentFrameMeasurements,
              ),
            ),
            ),

            IgnorePointer(child: CustomPaint(
                size: Size.infinite,
                painter: ActiveMeasurementPainter(
                    point1,
                    point2,
                    measurePoint1,
                    measurePoint2,
                ),
            ),
            ),

            if (showMethodSelection)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Text(
                      "Choose Measurement Method",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text(
                          "AI Measure",
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VideoMeasurementResultScreen(
                                    imagePath: widget.imagePath,
                                    videoPath: widget.videoPath,
                                    frameTimeMs: widget.frameTimeMs,
                                    aiX: aiX,
                                    aiY: aiY,
                                    aiWidth: aiWidth,
                                    aiHeight: aiHeight,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.straighten),
                        label: const Text(
                          "Manual Measure",
                        ),
                        onPressed: () {
                          setState(() {
                            showMethodSelection = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
          ...currentFrameMeasurements.map(
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
          ...currentFrameMeasurements.map(
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
            left: (measurePoint1!.dx + measurePoint2!.dx) / 2 - 35,
            top: (measurePoint1!.dy + measurePoint2!.dy) / 2 - 50,
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

            

            if (!showMethodSelection &&
                point1 != null &&
                point2 != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    30,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                    ),
                    boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                    ),
                    ],
                ),
                child: SizedBox(
                  height: 220,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(!isCalibrated) ...[
                        const Text(
                            "Reference Calibration",
                            style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                            ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                            "Pixels: ${calculateDistance().toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: sizeController,
                        keyboardType:
                            TextInputType.number,
                        style: const TextStyle(
                            color: Colors.black87,
                        ),
                        decoration:
                            const InputDecoration(
                          hintText:
                              "Enter actual size in cm",
                          hintStyle: TextStyle(
                            color: Colors.grey,
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

                            isCalibrated = true;
                            measurementMode = true;
                          });
                        },
                        child:
                            const Text("CALIBRATE"),
                      ),

                      const SizedBox(height: 8),

                    OutlinedButton.icon(
                    onPressed: () {
                        setState(() {
                        point1 = null;
                        point2 = null;
                        pixelsPerCm = 0;
                        });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                        "RESET CALIBRATION",
                    ),
                    
                ),
                ],

                      const SizedBox(height: 10),


                      if (isCalibrated)
                        Column(
                            children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Calibrated",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              value: selectedDimension,
                              decoration: const InputDecoration(
                                labelText: "Select Dimension",
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Width", child: Text("Width")),
                                DropdownMenuItem(value: "Height", child: Text("Height")),
                                DropdownMenuItem(value: "Depth", child: Text("Depth")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedDimension = value!;
                                });
                              },
                            ),

                            const SizedBox(height: 10),

                            OutlinedButton.icon(
                            onPressed: () {
                                setState(() {
                                measurePoint1 = null;
                                measurePoint2 = null;
                                });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                                "RESET MEASUREMENT",
                            ),
                            ),
                            ],
                        ),

                        if (isCalibrated &&
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

                        if (readyToSave)

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    measurements,
                                  );
                                },
                                icon: const Icon(
                                  Icons.photo_library,
                                ),
                                label: const Text(
                                  "SELECT ANOTHER FRAME",
                                ),
                              ),
                            ),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                            "${measurements.length} Measurements Saved",
                            style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                        ],
                    ),
                    ),
                    ],
                  ),
                ),
              ),
                ),
              ),
          ],
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

class ActiveMeasurementPainter extends CustomPainter {
  final Offset? point1;
  final Offset? point2;
  final Offset? measurePoint1;
  final Offset? measurePoint2;

  ActiveMeasurementPainter(
    this.point1,
    this.point2,
    this.measurePoint1,
    this.measurePoint2,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final calibrationPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3;

    final measurementPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    if (point1 != null && point2 != null) {
      canvas.drawLine(
        point1!,
        point2!,
        calibrationPaint,
      );
    }

    if (measurePoint1 != null &&
        measurePoint2 != null) {
      canvas.drawLine(
        measurePoint1!,
        measurePoint2!,
        measurementPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {
    return true;
  }
}
