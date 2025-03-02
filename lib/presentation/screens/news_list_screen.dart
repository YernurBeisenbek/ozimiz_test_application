import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/news_bloc.dart';
import 'add_news_screen.dart';
import 'dart:io';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: () {
              context.read<NewsBloc>().add(FetchNewsFromApiEvent());
            },
          )
        ],
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is NewsLoadingState) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is NewsErrorState) {
            return Center(child: Text(state.message));
          }
          if (state is NewsLoadedState) {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: state.localNews.length + state.apiNews.length,
              itemBuilder: (context, index) {
                final bool isLocalNews = index < state.localNews.length;
                final news = isLocalNews
                    ? state.localNews[index]
                    : state.apiNews[index - state.localNews.length];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (news.imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: news.imagePath!.startsWith('http')
                                ? Image.network(
                                    news.imagePath!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey[600]),
                                  )
                                : File(news.imagePath!).existsSync()
                                    ? Image.file(
                                        File(news.imagePath!),
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.image,
                                            size: 50, color: Colors.grey[600]),
                                      ),
                          ),
                        SizedBox(height: 8),
                        Text(
                          news.title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          news.description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              news.date,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (isLocalNews)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddNewsScreen(
                                              editingNews: news, index: index),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      context
                                          .read<NewsBloc>()
                                          .add(DeleteNewsEvent(index));
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text("No news available"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddNewsScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
