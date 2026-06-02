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
    
    controller.addListener(() {
        if (mounted) {
            setState(() {});
        }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) =>
        n.toString().padLeft(2, '0');

    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
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
                GestureDetector(
                    onTap: () {
                    if (controller.value.isPlaying) {
                        controller.pause();
                    } else {
                        controller.play();
                    }

                    setState(() {});
                    },
                    child: AspectRatio(
                    aspectRatio:
                        controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                    ),
                ),

                if (!controller.value.isPlaying)
                    IconButton(
                    iconSize: 80,
                    icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                    ),
                    onPressed: () {
                        controller.play();
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

            const SizedBox(height: 10),

            Padding(
                padding: const EdgeInsets.symmetric(
                horizontal: 16,
                ),
                child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                    formatDuration(
                        controller.value.position,
                    ),
                    style: const TextStyle(
                        color: Colors.white,
                    ),
                    ),
                    Text(
                    formatDuration(
                        controller.value.duration,
                    ),
                    style: const TextStyle(
                        color: Colors.white,
                    ),
                    ),
                ],
                ),
            ),
            ],
        )
        : const Center(
            child: CircularProgressIndicator(),
        ),
    );
  }
}