class ColorEntity {
  final String code;
  final String name;
  final String audio;

  ColorEntity({
    required this.code,
    required this.name,
    required this.audio,
  });

  factory ColorEntity.fromJson(Map<String, dynamic> parsedJson) {
    return ColorEntity(
      code: parsedJson['code'] ?? '',
      name: parsedJson['name'] ?? '',
      audio: parsedJson['audio'] ?? '',
    );
  }
}
