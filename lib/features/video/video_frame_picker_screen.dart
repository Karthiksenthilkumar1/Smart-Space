import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import 'frame_preview_screen.dart';

class VideoFramePickerScreen extends StatefulWidget {
  final String videoPath;
  final List<Map<String, dynamic>>? savedMeasurements;

  const VideoFramePickerScreen({
    super.key,
    required this.videoPath,
    this.savedMeasurements,
  });

  @override
  State<VideoFramePickerScreen> createState() =>
      _VideoFramePickerScreenState();
}

class _VideoFramePickerScreenState
    extends State<VideoFramePickerScreen> {

  late VideoPlayerController controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    controller =
        VideoPlayerController.file(
      File(widget.videoPath),
    );

    await controller.initialize();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> useCurrentFrame() async {
    final position =
        controller.value.position;
    
    print(
      "Selected position: ${position.inMilliseconds}",
    );

    final tempDir =
    await getTemporaryDirectory();

    final uniquePath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png";

    final framePath =
        await vt.VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      thumbnailPath: uniquePath,
      imageFormat: vt.ImageFormat.PNG,
      quality: 100,
      timeMs: position.inMilliseconds,
    );
    print(
      "Frame path: $framePath",
    );

    if (framePath == null || !mounted) {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FramePreviewScreen(
          imagePath: framePath,
          videoPath: widget.videoPath,
          savedMeasurements:
              widget.savedMeasurements,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoFramePickerScreen(
            videoPath: widget.videoPath,
            savedMeasurements:
                List<Map<String, dynamic>>.from(result),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          "Select Frame",
        ),
      ),
      body: Column(
        children: [

          SizedBox(
            height: 300,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              return Slider(
                min: 0,
                max: value.duration
                    .inMilliseconds
                    .toDouble(),
                value: value.position
                    .inMilliseconds
                    .toDouble()
                    .clamp(
                      0,
                      value.duration
                          .inMilliseconds
                          .toDouble(),
                    ),
                onChanged: (newValue) {
                  controller.seekTo(
                    Duration(
                      milliseconds:
                          newValue.toInt(),
                    ),
                  );
                },
              );
            },
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              IconButton(
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    if (controller
                        .value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Padding(
            padding:
                const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    useCurrentFrame,
                child: const Text(
                  "USE THIS FRAME",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}