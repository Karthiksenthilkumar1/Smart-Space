import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPreviewScreen> createState() =>
      _VideoPreviewScreenState();
}

class _VideoPreviewScreenState
    extends State<VideoPreviewScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(
      Uri.file(widget.videoPath).toFilePath().isNotEmpty
          ? throw UnimplementedError()
          : throw UnimplementedError(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}