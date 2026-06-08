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
  int pausedPositionMs = 0;
  double playbackSpeed = 1.0;

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

    await controller.pause();

    pausedPositionMs =
      controller.value.position.inMilliseconds;

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    final position =
      controller.value.position;

    print(
      "PLAYER POSITION = ${position.inMilliseconds}",
    );

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
          frameTimeMs:
              position.inMilliseconds,
        )
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
            height: MediaQuery.of(context).size.height * 0.50,
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

          const SizedBox(height: 12),
          
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [

                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    return Slider(
                      min: 0,
                      max: value.duration.inMilliseconds.toDouble(),
                      value: value.position.inMilliseconds
                          .toDouble()
                          .clamp(
                            0,
                            value.duration.inMilliseconds.toDouble(),
                          ),
                      onChanged: (newValue) async {
                        await controller.seekTo(
                          Duration(
                            milliseconds: newValue.toInt(),
                          ),
                        );

                        print(
                          "SLIDER = ${newValue.toInt()}",
                        );

                        print(
                          "AFTER SEEK = ${controller.value.position.inMilliseconds}",
                        );

                        setState(() {});
                      },
                    );
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            playbackSpeed == 0.25
                                ? Colors.indigo
                                : Colors.grey.shade300,
                        foregroundColor:
                            playbackSpeed == 0.25
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () async {
                        await controller.setPlaybackSpeed(0.25);

                        setState(() {
                          playbackSpeed = 0.25;
                        });
                      },
                      child: const Text("0.25x"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            playbackSpeed == 0.5
                                ? Colors.indigo
                                : Colors.grey.shade300,
                        foregroundColor:
                            playbackSpeed == 0.5
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () async {
                        await controller.setPlaybackSpeed(0.5);

                        setState(() {
                          playbackSpeed = 0.5;
                        });
                      },
                      child: const Text("0.5x"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            playbackSpeed == 1.0
                                ? Colors.indigo
                                : Colors.grey.shade300,
                        foregroundColor:
                            playbackSpeed == 1.0
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () async {
                        await controller.setPlaybackSpeed(1.0);

                        setState(() {
                          playbackSpeed = 1.0;
                        });
                      },
                      child: const Text("1.0x"),
                    )
                  ],
                ),

                IconButton(
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  iconSize: 40,
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {

                       controller.pause();

                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () {
                            pausedPositionMs =
                                controller.value.position.inMilliseconds;

                            print(
                              "PAUSED AT = $pausedPositionMs",
                            );
                          },
                        );

                        print(
                          "PAUSED AT = $pausedPositionMs",
                        );
                      } else {
                        controller.play();
                      }
                    });
                  },
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: useCurrentFrame,
                    child: const Text(
                      "USE THIS FRAME",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}