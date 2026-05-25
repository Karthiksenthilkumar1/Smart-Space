import 'dart:io';
import 'package:flutter/material.dart';
import 'suggestions_screen.dart';
import 'package:smart_space/core/services/api_service.dart';

class MeasurementResultScreen extends StatefulWidget {
  final String? imagePath;

  const MeasurementResultScreen({
    super.key,
    this.imagePath,
  });

  @override
  State<MeasurementResultScreen> createState() =>
      _MeasurementResultScreenState();
}

class _MeasurementResultScreenState
    extends State<MeasurementResultScreen> {
  bool isLoading = true;

  double width = 0;
  double height = 0;
  double depth = 0;
  double area = 0;

  String roomType = "Study Room";
  int confidence = 94;
  String method = "";

  @override
  void initState() {
    super.initState();
    _loadMeasurement();
  }

  Future<void> _loadMeasurement() async {
    final response =
      await ApiService.analyzeMeasurement(
    imagePath: widget.imagePath,
  );

    if (response["statusCode"] == 200) {
      final measurement =
          response["data"]["measurement"];

      setState(() {
        width = measurement["width"].toDouble();
        height = measurement["height"].toDouble();
        depth = measurement["depth"].toDouble();
        area = measurement["area"].toDouble();

        roomType =
            measurement["roomType"] ??
                "Study Room";

        confidence =
            measurement["confidence"] ?? 94;

        method =
            measurement["method"] ?? "";

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: const Text(
          "AI Measurement Result",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: widget.imagePath != null
                      ? Image.file(
                          File(widget.imagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.indigo.shade50,
                          child: const Center(
                            child: Icon(
                              Icons.home_work,
                              size: 120,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                ),

                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$roomType",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 60,
                  left: 40,
                  right: 40,
                  bottom: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                _tag(
                  "${width.toInt()} cm",
                  top: 50,
                  right: 60,
                ),

                _tag(
                  "${height.toInt()} cm",
                  top: 145,
                  left: 18,
                ),

                _tag(
                  "${depth.toInt()} cm",
                  bottom: 70,
                  left: 80,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor:
                      Color(0xFFEFF1FF),
                  child: Icon(
                    Icons.verified,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$roomType Analysis Complete",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AI confidence: $confidence%",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _metricCard(
                  "Width",
                  "${width.toInt()} cm",
                  Icons.straighten,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metricCard(
                  "Height",
                  "${height.toInt()} cm",
                  Icons.height,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _metricCard(
                  "Depth",
                  "${depth.toInt()} cm",
                  Icons.square_foot,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _metricCard(
                  "Area",
                  "${area.toStringAsFixed(2)} m²",
                  Icons.grid_view,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Analysis Method: $method",
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final response =
                        await ApiService.saveScan(
                      imagePath:
                          widget.imagePath,
                      width: width,
                      height: height,
                      depth: depth,
                      area: area,
                      roomType: roomType,
                    );

                    if (response[
                            "statusCode"] ==
                        201) {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Scan saved successfully",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            response["data"]
                                    ["message"] ??
                                "Failed to save scan",
                          ),
                        ),
                      );
                    }
                  },
                  style:
                      OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    side: const BorderSide(
                      color: Colors.indigo,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                  ),
                  child:
                      const Text("Save Result"),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SuggestionsScreen(
                          width: width,
                          height: height,
                          depth: depth,
                          area: area,
                          roomType: roomType,
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.indigo,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                  ),
                  child: const Text(
                    "View Suggestions",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style:
                const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _tag(
    String text, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}