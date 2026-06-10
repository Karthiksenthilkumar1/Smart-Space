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
        final measurements =
            jsonDecode(video["measurements"]);

        measurementCount = measurements
            .where(
                (m) =>
                    m["measurementType"] ==
                    "OBJECT_3D",
            )
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
                        Text(
                            video["title"] ??
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

                    Column(
                    children: [
                        IconButton(
                        icon: const Icon(
                            Icons.edit,
                            color: Colors.indigo,
                        ),
                        onPressed: () async {
                            final controller =
                                TextEditingController(
                            text: video["title"] ??
                                "Video Scan",
                            );

                            final newTitle =
                                await showDialog<String>(
                            context: context,
                            builder: (_) => AlertDialog(
                                title:
                                    const Text("Rename Video"),
                                content: TextField(
                                controller: controller,
                                ),
                                actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child:
                                        const Text("Cancel"),
                                ),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                    context,
                                    controller.text,
                                    ),
                                    child:
                                        const Text("Save"),
                                ),
                                ],
                            ),
                            );

                            if (newTitle == null ||
                                newTitle.trim().isEmpty) {
                            return;
                            }

                            final result =
                                await ApiService.updateVideo(
                            videoId:
                                video["id"].toString(),
                            title: newTitle.trim(),
                            );

                            if (result["statusCode"] == 200) {
                            loadVideos();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                                const SnackBar(
                                content:
                                    Text("Video Renamed"),
                                ),
                            );
                            }
                        },
                        ),
                        IconButton(
                        icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                        ),
                        onPressed: () async {
                        final confirm =
                            await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                            title: const Text(
                                "Delete Scan?",
                            ),
                            content: const Text(
                                "This action cannot be undone.",
                            ),
                            actions: [
                                TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                    context,
                                    false,
                                ),
                                child: const Text(
                                    "Cancel",
                                ),
                                ),
                                ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(
                                    context,
                                    true,
                                ),
                                child: const Text(
                                    "Delete",
                                ),
                                ),
                            ],
                            ),
                        );

                        if (confirm != true) return;
                        print("Deleting ID: ${video["id"]}");

                        final result =
                            await ApiService.deleteVideo(
                                video["id"].toString(),
                            );
                        print(result);

                        if (result["statusCode"] == 200) {
                            loadVideos();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                            const SnackBar(
                                content: Text(
                                "Scan Deleted",
                                ),
                            ),
                            );
                        }
                        },
                        ),

                        const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        ),
                    ],
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