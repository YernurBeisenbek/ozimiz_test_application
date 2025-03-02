
import 'package:hive/hive.dart';
import '../models/news_model.dart';

class NewsRepository {
  final Box<NewsModel> newsBox = Hive.box<NewsModel>('newsBox');

  List<NewsModel> getLocalNews() {
    return newsBox.values.toList();
  }

  void addNews(NewsModel news) {
    newsBox.add(news);
  }

  void deleteNews(int index) {
    newsBox.deleteAt(index);
  }

  void editNews(int index, NewsModel updatedNews) {
    newsBox.putAt(index, updatedNews);
  }
}
