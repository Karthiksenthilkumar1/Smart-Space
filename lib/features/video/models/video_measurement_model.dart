class VideoMeasurementModel {
  final String videoPath;
  final String thumbnailPath;
  final double pixelsPerCm;
  final List<Map<String, dynamic>> measurements;

  VideoMeasurementModel({
    required this.videoPath,
    required this.thumbnailPath,
    required this.pixelsPerCm,
    required this.measurements,
  });

  Map<String, dynamic> toJson() {
    return {
      "videoPath": videoPath,
      "thumbnailPath": thumbnailPath,
      "pixelsPerCm": pixelsPerCm,
      "measurements": measurements,
    };
  }

  factory VideoMeasurementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VideoMeasurementModel(
      videoPath: json["videoPath"],
      thumbnailPath: json["thumbnailPath"],
      pixelsPerCm: json["pixelsPerCm"].toDouble(),
      measurements:
          List<Map<String, dynamic>>.from(
        json["measurements"],
      ),
    );
  }
}