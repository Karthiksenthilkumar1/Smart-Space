import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'video_frame_picker_screen.dart';

import 'frame_preview_screen.dart';

class VideoCaptureScreen extends StatefulWidget {
  const VideoCaptureScreen({super.key});

  @override
  State<VideoCaptureScreen> createState() =>
      _VideoCaptureScreenState();
}

class _VideoCaptureScreenState
    extends State<VideoCaptureScreen> {
  CameraController? controller;

  final ImagePicker picker = ImagePicker();

  bool isLoading = true;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller!.initialize();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> startRecording() async {
    if (controller == null) return;

    await controller!.startVideoRecording();

    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording() async {
    if (controller == null) return;

    final video =
        await controller!.stopVideoRecording();

    setState(() {
      isRecording = false;
    });

    if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
            builder: (_) =>
                VideoFramePickerScreen(
                videoPath: video.path,
            ),
            ),
        );
    }
  }

  Future<void> pickVideoFromGallery() async {
    final XFile? video =
        await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return;

    if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
            builder: (_) =>
                VideoFramePickerScreen(
                videoPath: video.path,
            ),
            ),
        );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Room Video"),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(
              controller!,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isRecording
                          ? Icons.stop
                          : Icons.videocam,
                    ),
                    label: Text(
                      isRecording
                          ? "Stop Recording"
                          : "Start Recording",
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          isRecording
                              ? Colors.red
                              : Colors.indigo,
                    ),
                    onPressed: () {
                      if (isRecording) {
                        stopRecording();
                      } else {
                        startRecording();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed:
                        pickVideoFromGallery,
                    icon: const Icon(
                      Icons.video_library,
                    ),
                    label: const Text(
                      "Select From Gallery",
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