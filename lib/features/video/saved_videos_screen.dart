import 'dart:io';

import 'package:flutter/material.dart';

import 'models/video_measurement_model.dart';
import 'services/video_storage_service.dart';
import 'frame_preview_screen.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() =>
      _SavedVideosScreenState();
}

class _SavedVideosScreenState
    extends State<SavedVideosScreen> {
  List<VideoMeasurementModel> videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final data =
        await VideoStorageService.getSavedVideos();

    setState(() {
      videos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Videos"),
      ),
      body: videos.isEmpty
          ? const Center(
              child: Text(
                "No Saved Videos",
              ),
            )
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.file(
                        File(video.thumbnailPath),
                        width: 70,
                        fit: BoxFit.cover,
                    ),
                    title: Text(
                        "Room Scan ${index + 1}",
                    ),
                    subtitle: Text(
                        "${video.measurements.length} Measurements",
                    ),
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FramePreviewScreen(
                            imagePath: video.thumbnailPath,
                            videoPath: video.videoPath,
                            savedMeasurements:
                                video.measurements,
                            ),
                        ),
                        );
                    },
                    ),
                );
              },
            ),
    );
  }
}