import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../scan/suggestions_screen.dart';

class VideoMeasurementResultScreen extends StatefulWidget {
  final String imagePath;
  final String videoPath;
  final int frameTimeMs;
  final double aiX;
  final double aiY;
  final double aiWidth;
  final double aiHeight;

  const VideoMeasurementResultScreen({
    super.key,
    required this.imagePath,
    required this.videoPath,
    required this.frameTimeMs,
    required this.aiX,
    required this.aiY,
    required this.aiWidth,
    required this.aiHeight,
  });

  @override
  State<VideoMeasurementResultScreen> createState() =>
      _VideoMeasurementResultScreenState();
}

class _VideoMeasurementResultScreenState
    extends State<VideoMeasurementResultScreen> {
  bool isLoading = true;

  double width = 0;
  double height = 0;
  double depth = 0;
  double area = 0;

  String roomType = "Study Room";

  @override
  void initState() {
    super.initState();
    loadMeasurement();
  }

  Future<void> loadMeasurement() async {
    final response =
        await ApiService.analyzeMeasurement(
      imagePath: widget.imagePath,
    );

    if (response["statusCode"] == 200) {
      final measurement =
          response["data"]["measurement"];

      setState(() {
        width =
    (measurement["width"] ?? 0).toDouble();

        height =
            (measurement["height"] ?? 0).toDouble();

        depth =
            (measurement["depth"] ?? 0).toDouble();

        area =
            (measurement["area"] ?? 0).toDouble();

        if (width == 0 && widget.aiWidth > 0) {
          width = widget.aiWidth / 10;
        }

        if (height == 0 && widget.aiHeight > 0) {
          height = widget.aiHeight / 10;
        }

        if (depth == 0 && width > 0) {
          depth = width * 0.6;
        }

        if (area == 0 && width > 0 && depth > 0) {
          area = (width * depth) / 10000;
        }

        roomType =
            measurement["roomType"] ??
                "Study Room";

        isLoading = false;
      });
    } else {
      setState(() {
        width = widget.aiWidth > 0
            ? widget.aiWidth / 10
            : 0;

        height = widget.aiHeight > 0
            ? widget.aiHeight / 10
            : 0;

        depth = width > 0
            ? width * 0.6
            : 0;

        area = width > 0 && depth > 0
            ? (width * depth) / 10000
            : 0;

        roomType = "Detected Space";

        isLoading = false;
      });
    }
  }

  Future<void> saveAIVideoData() async {
    print("================================");
    print("AI SAVE DATA");
    print("X = ${widget.aiX}");
    print("Y = ${widget.aiY}");
    print("W = ${widget.aiWidth}");
    print("H = ${widget.aiHeight}");
    print("================================");
    final result = await ApiService.saveVideoScan(
        videoPath: widget.videoPath,
        thumbnailUrl: widget.imagePath,
        pixelsPerCm: 0,
        measurements: [
        {
            "name": "AI Detected Space",
            "distance": width,
            "frameTimeMs": widget.frameTimeMs,
            "frameImage": widget.imagePath,

            "point1x": widget.aiX,
            "point1y": widget.aiY,

            "point2x": widget.aiX + widget.aiWidth,
            "point2y": widget.aiY,

            "aiX": widget.aiX,
            "aiY": widget.aiY,
            "aiWidth": widget.aiWidth,
            "aiHeight": widget.aiHeight,

            "width": width,
            "height": height,
            "depth": depth,
            "area": area,
            "roomType": roomType,
            "measurementType": "AI",
        }
        ],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(
            result["statusCode"] == 201
                ? "AI Video Measurement Saved"
                : "Save Failed",
        ),
        ),
    );
    }

  Widget _measurementTile(
    IconData icon,
    String title,
    String value,
    ) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
        children: [
            Icon(icon, size: 22, color: Colors.deepPurple),
            const SizedBox(width: 14),
            Expanded(
            child: Text(
                title,
                style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                ),
            ),
            ),
            Text(
            value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
            ),
            ),
        ],
        ),
    );
    }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Video AI Measurement",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            children: [
            Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(22),
                ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                ),
                ),
            ),

            const Spacer(),

            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: const Color(0xFFF4EFFF),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    ),
                ],
                ),
                child: Column(
                children: [
                    Text(
                    roomType,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                    ),
                    ),

                    const SizedBox(height: 18),

                    _measurementTile(Icons.straighten, "Width", "${width.toStringAsFixed(0)} cm"),
                    _measurementTile(Icons.height, "Height", "${height.toStringAsFixed(0)} cm"),
                    _measurementTile(Icons.square_foot, "Depth", "${depth.toStringAsFixed(0)} cm"),
                    _measurementTile(Icons.grid_view, "Area", "${area.toStringAsFixed(2)} m²"),
                ],
                ),
            ),

            const SizedBox(height: 20),

            SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    ),
                ),
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SuggestionsScreen(
                        width: width,
                        height: height,
                        depth: depth,
                        area: area,
                        roomType: roomType,
                        ),
                    ),
                    );
                },
                child: const Text(
                    "VIEW SUGGESTIONS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ),
            ),

            const SizedBox(height: 12),

                SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text(
                    "SAVE VIDEO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: saveAIVideoData,
                ),
                ),
            ],
        ),
        ),
    );
  }
}