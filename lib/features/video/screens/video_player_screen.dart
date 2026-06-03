import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final List measurements;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.measurements,
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

  List getVisibleMeasurements() {
    final currentTime =
        controller.value.position.inMilliseconds;

    return widget.measurements.where((m) {
        final frameTime =
            (m["frameTimeMs"] ?? 0) as int;

        return (currentTime - frameTime).abs() <= 1500;
    }).toList();
  }
  
  Widget buildMeasurementOverlay() {
    final visibleMeasurements =
        getVisibleMeasurements();

    if (visibleMeasurements.isEmpty) {
        return const SizedBox();
    }

    return Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: visibleMeasurements.map<Widget>(
            (m) {
                return Padding(
                padding:
                    const EdgeInsets.symmetric(
                    vertical: 4,
                ),
                child: Row(
                    children: [
                    const Icon(
                        Icons.straighten,
                        color: Colors.green,
                        size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                        child: Text(
                        m["name"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                        ),
                        ),
                    ),

                    Text(
                        "${(m["distance"] as num).toDouble().toStringAsFixed(1)} cm",
                        style: const TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                        ),
                    ),
                    ],
                ),
                );
            },
            ).toList(),
        ),
        ),
    );
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
                child: Stack(
                    children: [
                    Positioned.fill(
                        child: VideoPlayer(controller),
                    ),

                    buildMeasurementOverlay(),
                    ],
                ),
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
