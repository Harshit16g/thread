import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  @override
  Future<List<Post>> getFeed() async {
    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((data) => _mapToPost(data)).toList();
  }

  @override
  Future<void> createPost(String content, {String? roomId, Map<String, dynamic>? metadata}) async {
    await _client.from('posts').insert({
      'room_id': roomId,
      'author_id': _client.auth.currentUser!.id,
      'content': content,
      'metadata': metadata,
    });
  }

  Post _mapToPost(Map<String, dynamic> data) {
    return Post(
      id: data['id'],
      roomId: data['room_id'],
      authorId: data['author_id'],
      content: data['content'],
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}
