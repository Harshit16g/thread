import 'package:equatable/equatable.dart';
import '../../../domain/entities/post.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeed extends PostsEvent {}
