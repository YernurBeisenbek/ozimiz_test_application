import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/news.dart';
import '../../domain/usecases/manage_news.dart';

abstract class NewsEvent {}
class LoadNewsEvent extends NewsEvent {}
class AddNewsEvent extends NewsEvent { final News news; AddNewsEvent(this.news); }
class DeleteNewsEvent extends NewsEvent { final int index; DeleteNewsEvent(this.index); }
class FetchNewsFromApiEvent extends NewsEvent {}
class EditNewsEvent extends NewsEvent { final int index; final News news; EditNewsEvent(this.index, this.news); }

abstract class NewsState {}

class NewsInitialState extends NewsState {}
class NewsLoadingState extends NewsState {}
class NewsLoadedState extends NewsState {
  final List<News> localNews;
  final List<News> apiNews;
  NewsLoadedState({required this.localNews, required this.apiNews});
}
class NewsErrorState extends NewsState {
  final String message;
  NewsErrorState(this.message);
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final ManageNews manageNews;

  NewsBloc(this.manageNews) : super(NewsInitialState()) {
    on<LoadNewsEvent>((event, emit) {
      emit(NewsLoadingState());
      try {
        final localNews = manageNews.getLocalNews();
        emit(NewsLoadedState(localNews: localNews, apiNews: []));
      } catch (e) {
        emit(NewsErrorState("Failed to load local news"));
      }
    });

    on<AddNewsEvent>((event, emit) {
      manageNews.addNews(event.news);
      emit(NewsLoadedState(localNews: manageNews.getLocalNews(), apiNews: (state is NewsLoadedState) ? (state as NewsLoadedState).apiNews : []));
    });

    on<DeleteNewsEvent>((event, emit) {
      manageNews.deleteNews(event.index);
      emit(NewsLoadedState(localNews: manageNews.getLocalNews(), apiNews: (state is NewsLoadedState) ? (state as NewsLoadedState).apiNews : []));
    });

    on<EditNewsEvent>((event, emit) {
      manageNews.editNews(event.index, event.news);
      emit(NewsLoadedState(localNews: manageNews.getLocalNews(), apiNews: (state is NewsLoadedState) ? (state as NewsLoadedState).apiNews : []));
    });

    on<FetchNewsFromApiEvent>((event, emit) async {
      emit(NewsLoadingState());
      try {
        final apiNews = await manageNews.fetchAndSaveNews();
        emit(NewsLoadedState(localNews: (state is NewsLoadedState) ? (state as NewsLoadedState).localNews : [], apiNews: apiNews));
      } catch (e) {
        emit(NewsErrorState("Failed to fetch news from API"));
      }
    });
  }
}
