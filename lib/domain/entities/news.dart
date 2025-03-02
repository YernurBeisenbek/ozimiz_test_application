class News {
  final String title;
  final String description;
  final String date;
  final String? imagePath;

  News({
    required this.title,
    required this.description,
    required this.date,
    this.imagePath,
  });
}
