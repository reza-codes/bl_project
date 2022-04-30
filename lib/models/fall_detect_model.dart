class FallDetectModel {
  final String id;
  final double longitude;
  final double latitude;
  final DateTime dataTime;

  FallDetectModel({
    required this.id,
    required this.longitude,
    required this.latitude,
    required this.dataTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'longitude': longitude,
        'latitude': latitude,
        'dataTime': dataTime,
      };

  FallDetectModel fromJson(Map<String, dynamic> json) => FallDetectModel(
        id: json['id'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        dataTime: json['dataTime'],
      );
}
