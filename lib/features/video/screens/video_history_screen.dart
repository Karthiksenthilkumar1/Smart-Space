import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import 'video_detail_screen.dart';

class VideoHistoryScreen extends StatefulWidget {
  const VideoHistoryScreen({super.key});

  @override
  State<VideoHistoryScreen> createState() =>
      _VideoHistoryScreenState();
}

class _VideoHistoryScreenState
    extends State<VideoHistoryScreen> {
  bool isLoading = true;
  List videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final response =
        await ApiService.getMyVideos();

    if (response["statusCode"] == 200) {
      setState(() {
        videos = response["data"]["videos"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (videos.isEmpty) {
      return const Center(
        child: Text("No Saved Videos"),
      );
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];

        int measurementCount = 0;

        try {
        measurementCount =
            jsonDecode(video["measurements"])
                .length;
        } catch (_) {
        measurementCount = 0;
        }

        return GestureDetector(
        onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    VideoDetailScreen(
                video: video,
                ),
            ),
            );
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
            ),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            boxShadow: [
                BoxShadow(
                color: Colors.black.withOpacity(
                    0.05,
                ),
                blurRadius: 10,
                ),
            ],
            ),
            child: Column(
            children: [
                ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                    top: Radius.circular(20),
                ),
                child: Image.network(
                    video["thumbnailUrl"],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) {
                    return Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Center(
                        child: Icon(
                            Icons.videocam,
                            size: 50,
                            color: Colors.indigo,
                        ),
                        ),
                    );
                    },
                ),
                ),

                Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Row(
                    children: [
                    const CircleAvatar(
                        backgroundColor:
                            Colors.indigo,
                        child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                        const Text(
                            "Video Scan",
                            style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                            video["createdAt"]
                                .toString()
                                .substring(0, 10),
                            style: const TextStyle(
                            color: Colors.grey,
                            ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                            measurementCount == 1
                            ? "1 Measurement"
                            : "$measurementCount Measurements",
                            style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        ],
                    ),
                    ),

                    const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                    ),
                    ],
                ),
                ),
            ],
            ),
        ),
        );
      },
    );
  }
}