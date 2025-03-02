import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_model.dart';

class NewsApiService {
  final Dio _dio = Dio();
  final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  Future<List<NewsModel>> fetchNews() async {
    try {
      final response = await _dio.get(
        'https://newsapi.org/v2/top-headlines',
        queryParameters: {'country': 'us', 'apiKey': apiKey},
      );

      if (response.statusCode == 200) {
        List<NewsModel> newsList = (response.data['articles'] as List)
            .map((json) => NewsModel(
                  title: json['title'] ?? 'No title',
                  description: json['description'] ?? 'No description',
                  date: json['publishedAt'] ?? DateTime.now().toIso8601String(),
                  imagePath: json['urlToImage'],
                ))
            .toList();
        return newsList;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
