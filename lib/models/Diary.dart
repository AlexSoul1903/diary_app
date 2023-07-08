class DiaryEntry {
  late final String title;
  final String date;
  late final String description;
  late final String photo;
  late final String audio;
  final int? id;
  DiaryEntry({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.photo,
    required this.audio,
  });
}
