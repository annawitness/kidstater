class NumberEntity {
  final String text;
  final String audio;

  NumberEntity({
    required this.text,
    required this.audio,
  });

  factory NumberEntity.fromJson(Map<String, dynamic> parsedJson) {
    return NumberEntity(
      text: parsedJson['number'] ?? '',
      audio: parsedJson['audio'] ?? '',
    );
  }
}
