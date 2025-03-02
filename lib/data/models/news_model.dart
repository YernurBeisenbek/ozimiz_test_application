import 'package:hive/hive.dart';
part 'news_model.g.dart';

@HiveType(typeId: 0)
class NewsModel extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String? imagePath;

  NewsModel({required this.title, required this.description, required this.date, this.imagePath});
}
