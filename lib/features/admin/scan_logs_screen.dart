import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'package:smart_space/features/admin/scan_detail_screen.dart';

class ScanLogsScreen extends StatefulWidget {
  const ScanLogsScreen({super.key});

  @override
  State<ScanLogsScreen> createState() => _ScanLogsScreenState();
}

class _ScanLogsScreenState extends State<ScanLogsScreen> {
  bool isLoading = true;
  List scanLogs = [];
  List filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _loadScanLogs();
  }

  Future<void> _loadScanLogs() async {
    final response = await ApiService.getScanLogs();

    if (response["statusCode"] == 200) {
      setState(() {
        scanLogs = response["data"]["scanLogs"];
        filteredLogs = scanLogs;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _filterLogs(String query) {
    setState(() {
      filteredLogs = scanLogs.where((log) {
        final user = (log["userName"] ?? "").toString().toLowerCase();
        final room = (log["roomType"] ?? "").toString().toLowerCase();
        final email = (log["userEmail"] ?? "").toString().toLowerCase();

        return user.contains(query.toLowerCase()) ||
            room.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  String _formatDate(String? date) {
    if (date == null) return "Unknown time";

    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) return "Unknown time";

    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year} • ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}";
  }

  Widget _scanImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          height: 64,
          width: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackIcon();
          },
        ),
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.camera_alt,
        color: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Scan Logs"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  onChanged: _filterLogs,
                  decoration: InputDecoration(
                    hintText: "Search by user, email or room",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (filteredLogs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "No scan logs found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ...filteredLogs.map((log) {
                  return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanDetailScreen(
                          scanId: log["id"],
                          scanType: log["scanType"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _scanImage(log["imageUrl"]),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: log["scanType"] == "VIDEO"
                                        ? Colors.orange.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        log["scanType"] == "VIDEO"
                                            ? Icons.videocam
                                            : Icons.photo_camera,
                                        size: 14,
                                        color: log["scanType"] == "VIDEO"
                                            ? Colors.orange
                                            : Colors.blue,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        log["scanType"] == "VIDEO"
                                            ? "Video Scan"
                                            : "Image Scan",
                                        style: TextStyle(
                                          color: log["scanType"] == "VIDEO"
                                              ? Colors.orange
                                              : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  log["scanType"] == "VIDEO"
                                      ? "${log["userName"] ?? "Unknown User"} • Video Measurement"
                                      : "${log["userName"] ?? "Unknown User"} • ${log["roomType"] ?? "Unknown Room"}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                log["userEmail"] ?? "No email",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (log["scanType"] != "VIDEO")
                                Text(
                                  "${log["width"]?.toStringAsFixed(1) ?? "-"} × ${log["height"]?.toStringAsFixed(1) ?? "-"} × ${log["depth"]?.toStringAsFixed(1) ?? "-"} cm",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),

                              if (log["scanType"] == "VIDEO")
                                const Text(
                                  "Video Measurement Session",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),  

                              const SizedBox(height: 5),

                              Text(
                                _formatDate(log["createdAt"]),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  );
                }
                ),
              ],
            ),
    );
  }
}