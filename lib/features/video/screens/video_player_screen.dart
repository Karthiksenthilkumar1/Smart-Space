import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState
    extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller =
        VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  
      appBar: AppBar(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    title: const Text("Video Player"),
    ),
      body: controller.value.isInitialized
          ? Column(
              children: [
                Stack(
                alignment: Alignment.center,
                children: [
                    AspectRatio(
                    aspectRatio:
                        controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                    ),

                    IconButton(
                    iconSize: 70,
                    icon: Icon(
                        controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: Colors.white,
                    ),
                    onPressed: () {
                        if (controller.value.isPlaying) {
                        controller.pause();
                        } else {
                        controller.play();
                        }

                        setState(() {});
                    },
                    ),
                ],
                ),

                Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12,
            ),
            child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                playedColor: Colors.indigo,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white24,
                ),
            ),
            ),

                const SizedBox(height: 20),
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator(),
            ),
    );
  }
}