import 'dart:io';

import '../entities/news.dart';
import '../../data/local_storage/news_repository.dart';
import '../../data/remote/news_api_service.dart';
import '../../data/models/news_model.dart';

class ManageNews {
  final NewsRepository repository;
  final NewsApiService apiService;

  ManageNews(this.repository, this.apiService);

  /// Fetch locally stored news
  List<News> getLocalNews() {
    return repository.getLocalNews().map((newsModel) {
      // Ensure local images still exist
      String? imagePath = newsModel.imagePath;
      if (imagePath != null &&
          !imagePath.startsWith('http') &&
          !File(imagePath).existsSync()) {
        imagePath = null; // Remove missing local images
      }

      return News(
        title: newsModel.title,
        description: newsModel.description,
        date: newsModel.date,
        imagePath: imagePath,
      );
    }).toList();
  }

  /// Add a new news article to local storage
  void addNews(News news) {
    repository.addNews(NewsModel(
      title: news.title,
      description: news.description,
      date: news.date,
      imagePath: news.imagePath,
    ));
  }

  /// Delete a locally stored news article
  void deleteNews(int index) {
    repository.deleteNews(index);
  }

  /// Edit an existing locally stored news article
  void editNews(int index, News news) {
    repository.editNews(
        index,
        NewsModel(
          title: news.title,
          description: news.description,
          date: news.date,
          imagePath: news.imagePath,
        ));
  }

  /// Fetch news from the API and store it locally
  Future<List<News>> fetchAndSaveNews() async {
    List<NewsModel> apiNews = await apiService.fetchNews();

    // Convert API NewsModel to Entity News
    List<News> fetchedNews = apiNews
        .map((newsModel) => News(
              title: newsModel.title,
              description: newsModel.description,
              date: newsModel.date,
              imagePath: newsModel.imagePath,
            ))
        .toList();

    return fetchedNews;
  }
}
