import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/states/posts_state.dart';
import '../bloc/events/posts_event.dart';
import '../../domain/entities/post.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('TabL Threads', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PostsBloc>().add(LoadFeed());
        },
        color: Colors.amber,
        child: BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is PostsLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            } else if (state is PostsLoaded) {
              if (state.posts.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _buildPostCard(context, post);
                },
              );
            } else if (state is PostsError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            }
            return const Center(child: Text('Pull to refresh', style: TextStyle(color: Colors.white24)));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('The feed is empty', style: TextStyle(color: Colors.white38, fontSize: 16)),
          const Text('Collaborate in discussions to see posts here!', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.amber[900]!.withOpacity(0.2),
            radius: 18,
            child: const Icon(Icons.person, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'User ${post.authorId.substring(0, 4)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 16),
                    Icon(Icons.repeat, size: 18, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 16),
                    Icon(Icons.send_outlined, size: 18, color: Colors.white.withOpacity(0.4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
