import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getFeed();
  Future<void> createPost(String content, {String? roomId, Map<String, dynamic>? metadata});
}
