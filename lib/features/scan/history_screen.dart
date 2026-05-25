import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = true;
  List scans = [];

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    final response = await ApiService.getMyScans();

    if (response["statusCode"] == 200) {
      setState(() {
        scans = response["data"]["scans"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteScan(String id) async {
    final response = await ApiService.deleteScan(
      scanId: id,
    );

    if (response["statusCode"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scan deleted successfully"),
        ),
      );

      _loadScans();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ??
                "Failed to delete scan",
          ),
        ),
      );
    }
  }

  bool _isValidImageUrl(dynamic url) {
    if (url == null) return false;

    final value = url.toString().trim();

    if (value.isEmpty) return false;
    if (!value.startsWith("http")) return false;

    final uri = Uri.tryParse(value);

    return uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;
  }

  Widget _placeholderImage() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.home_work,
        color: Colors.indigo,
      ),
    );
  }

  Widget _imageBox(dynamic imageUrl) {
    if (_isValidImageUrl(imageUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl.toString(),
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _placeholderImage();
          },
        ),
      );
    }

    return _placeholderImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: const Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : scans.isEmpty
              ? const Center(
                  child: Text("No saved scans yet"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];

                    final width =
                        scan["width"] ?? 0;
                    final height =
                        scan["height"] ?? 0;
                    final depth =
                        scan["depth"] ?? 0;
                    final area =
                        scan["area"] ?? 0;

                    final size =
                        "${width.toString()} × ${height.toString()} × ${depth.toString()} cm";

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _imageBox(
                            scan["imageUrl"],
                          ),

                          const SizedBox(
                              width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Text(
                                  "Saved Measurement",
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(
                                    height: 4),

                                Text(
                                  scan["createdAt"]
                                      .toString()
                                      .substring(
                                          0, 10),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),

                                const SizedBox(
                                    height: 6),

                                Text(
                                  "$size • $area m²",
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.indigo,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              _deleteScan(
                                  scan["id"]);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}