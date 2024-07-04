class AlphabetEntity {
  final String? text;
  final String? audio;

  AlphabetEntity({
    this.text,
    this.audio,
  });

  factory AlphabetEntity.fromJson(Map<String, dynamic> parsedJson) {
    return AlphabetEntity(
      text: parsedJson['text'] as String?,
      audio: parsedJson['audio'] as String?,
    );
  }
}
