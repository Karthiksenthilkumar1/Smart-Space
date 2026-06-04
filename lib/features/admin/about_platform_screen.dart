import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class AboutPlatformScreen extends StatefulWidget {
  const AboutPlatformScreen({super.key});

  @override
  State<AboutPlatformScreen> createState() =>
      _AboutPlatformScreenState();
}

class _AboutPlatformScreenState
    extends State<AboutPlatformScreen> {

  bool isLoading = true;

  Map analytics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final response =
        await ApiService.getAnalytics();

    if (response["statusCode"] == 200) {
      setState(() {
        analytics =
            response["data"]["analytics"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget infoCard(
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FF),

      appBar: AppBar(
        title:
            const Text("About Platform"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [

                const CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      Colors.indigo,
                  child: Icon(
                    Icons.info,
                    size: 45,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    "SpaceFit Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const Center(
                  child: Text(
                    "Version 1.0",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                infoCard(
                  "Users",
                  "${analytics["users"]}",
                ),

                infoCard(
                  "Products",
                  "${analytics["products"]}",
                ),

                infoCard(
                  "Image Scans",
                  "${analytics["imageScans"]}",
                ),

                infoCard(
                  "Video Scans",
                  "${analytics["videoScans"]}",
                ),

                infoCard(
                  "Total Scans",
                  "${analytics["scans"]}",
                ),

                infoCard(
                  "Database",
                  "Connected",
                ),

                const SizedBox(height: 20),

                const Text(
                  "Technology Stack",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Flutter"),
                        Text(
                            "Node.js"),
                        Text(
                            "PostgreSQL"),
                        Text(
                            "Cloudinary"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}