import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'events/posts_event.dart';
import 'states/posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostRepository _postRepository;

  PostsBloc(this._postRepository) : super(PostsInitial()) {
    on<LoadFeed>(_onLoadFeed);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      final posts = await _postRepository.getFeed();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }
}
