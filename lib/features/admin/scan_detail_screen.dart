import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'package:smart_space/features/video/screens/video_detail_screen.dart';

class ScanDetailScreen extends StatefulWidget {
  final String scanId;
  final String scanType;

  const ScanDetailScreen({
    super.key,
    required this.scanId,
    required this.scanType,
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? scan;

  String formatDate(String? date) {
    if (date == null) return "-";

    final parsed = DateTime.parse(date);

    return DateFormat(
      'dd MMM yyyy • hh:mm a',
    ).format(parsed);
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final response = await ApiService.getScanLogDetails(
      widget.scanType,
      widget.scanId,
    );

    if (response["statusCode"] == 200) {
      setState(() {
        scan = response["data"]["scan"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || !imageUrl.startsWith("http")) {
      return const SizedBox();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Scan Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : scan == null
              ? const Center(
                  child: Text(
                    "Failed to load scan details",
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(
                        scan!["imageUrl"],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.scanType == "VIDEO"
                            ? "Video Scan"
                            : "Image Scan",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _infoTile(
                                "User",
                                scan!["userName"] ?? "-",
                              ),
                              _infoTile(
                                "Email",
                                scan!["userEmail"] ?? "-",
                              ),
                              _infoTile(
                                "Type",
                                widget.scanType,
                              ),
                              _infoTile(
                                "Created",
                                formatDate(
                                  scan!["createdAt"],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (widget.scanType == "IMAGE")
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _infoTile(
                                  "Room Type",
                                  scan!["roomType"]?.toString() ?? "-",
                                ),
                                _infoTile(
                                  "Width",
                                  "${scan!["width"]} cm",
                                ),
                                _infoTile(
                                  "Height",
                                  "${scan!["height"]} cm",
                                ),
                                _infoTile(
                                  "Depth",
                                  "${scan!["depth"]} cm",
                                ),
                                _infoTile(
                                  "Area",
                                  "${scan!["area"]} m²",
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (widget.scanType == "VIDEO")
                        Card(
                            child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                onPressed: () {
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => VideoDetailScreen(
                                        video: scan!,
                                        ),
                                    ),
                                    );
                                },
                                icon: const Icon(
                                    Icons.play_circle_fill,
                                ),
                                label: const Text(
                                    "Open Video Details",
                                    style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    ),
                                ),
                                ),
                            ),
                            ),
                        ),
                    ],
                  ),
                ),
    );
  }
}