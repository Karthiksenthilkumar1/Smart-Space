import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState
    extends State<DataManagementScreen> {

  bool isLoading = true;

  Map analytics = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

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

  Widget dataTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.indigo,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
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
            const Text("Data Management"),
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
                    Icons.storage,
                    size: 45,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                dataTile(
                  Icons.cloud_done,
                  "Database Status",
                  "Connected",
                ),

                dataTile(
                  Icons.people,
                  "Users",
                  "${analytics["users"]}",
                ),

                dataTile(
                  Icons.inventory_2,
                  "Products",
                  "${analytics["products"]}",
                ),

                dataTile(
                  Icons.photo_camera,
                  "Image Scans",
                  "${analytics["imageScans"]}",
                ),

                dataTile(
                  Icons.videocam,
                  "Video Scans",
                  "${analytics["videoScans"]}",
                ),

                dataTile(
                  Icons.camera_alt,
                  "Total Scans",
                  "${analytics["scans"]}",
                ),

                dataTile(
                  Icons.favorite,
                  "Saved Products",
                  "${analytics["savedProducts"]}",
                ),
              ],
            ),
    );
  }
}