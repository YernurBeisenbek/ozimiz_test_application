import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'application/blocs/news_bloc.dart';
import 'presentation/screens/news_list_screen.dart';
import 'data/models/news_model.dart';
import 'domain/usecases/manage_news.dart';
import 'data/local_storage/news_repository.dart';
import 'data/remote/news_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // api key load
  await Hive.initFlutter();
  Hive.registerAdapter(NewsModelAdapter());
  await Hive.openBox<NewsModel>('newsBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsBloc(ManageNews(NewsRepository(), NewsApiService()))..add(LoadNewsEvent()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News Feed',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: NewsListScreen(),
      ),
    );
  }
}
