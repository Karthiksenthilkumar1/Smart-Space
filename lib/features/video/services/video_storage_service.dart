import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/video_measurement_model.dart';

class VideoStorageService {
  static const String key = "saved_videos";

  static Future<void> saveVideo(
    VideoMeasurementModel video,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(key) ?? [];

    existing.add(
      jsonEncode(
        video.toJson(),
      ),
    );

    await prefs.setStringList(
      key,
      existing,
    );
  }

  static Future<List<VideoMeasurementModel>>
      getSavedVideos() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getStringList(key) ?? [];

    return data.map((item) {
      return VideoMeasurementModel.fromJson(
        jsonDecode(item),
      );
    }).toList();
  }
}