import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../rooms/domain/repositories/room_repository.dart';
import '../../../rooms/presentation/screens/room_chat_screen.dart';
import '../../../rooms/presentation/bloc/room_chat_bloc.dart';
import '../../../rooms/domain/entities/room.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _client = Supabase.instance.client;
  
  late TabController _tabController;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _userResults = [];
  List<Map<String, dynamic>> _postResults = [];
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      }
    });
    // Load default popular recommendations initially
    _loadPopularItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularItems() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = _client.auth.currentUser?.id;
      // Get some active users
      var usersQuery = _client.from('profiles').select();
      if (currentUserId != null) {
        usersQuery = usersQuery.neq('id', currentUserId);
      }
      final usersData = await usersQuery.limit(5);
      
      // Get some public discussion rooms/posts
      final postsData = await _client
          .from('rooms')
          .select()
          .eq('is_public', true)
          .limit(5);

      if (mounted) {
        setState(() {
          _userResults = List<Map<String, dynamic>>.from(usersData as List);
          _postResults = List<Map<String, dynamic>>.from(postsData as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[SearchScreen] Load initial error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadPopularItems();
      return;
    }

    setState(() {
      _isLoading = true;
      _activeQuery = query;
    });

    try {
      final currentUserId = _client.auth.currentUser?.id;

      if (_tabController.index == 0) {
        // Search Posts / Rooms
        final data = await _client
            .from('rooms')
            .select()
            .eq('is_public', true)
            .ilike('name', '%$query%')
            .limit(20);
            
        if (mounted) {
          setState(() {
            _postResults = List<Map<String, dynamic>>.from(data as List);
            _isLoading = false;
          });
        }
      } else {
        // Search Users
        var userQuery = _client
            .from('profiles')
            .select()
            .or('full_name.ilike.%$query%,email.ilike.%$query%');

        if (currentUserId != null) {
          userQuery = userQuery.neq('id', currentUserId);
        }

        final data = await userQuery.limit(20);

        if (mounted) {
          setState(() {
            _userResults = List<Map<String, dynamic>>.from(data as List);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[SearchScreen] Query error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initiateChat(BuildContext context, String targetUserId, String targetUserName) async {
    setState(() => _isLoading = true);
    final roomRepo = RepositoryProvider.of<RoomRepository>(context);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final room = await roomRepo.createPrivateChat(targetUserId, targetUserName);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Smoothly slide directly into the chat room using the captured navigator
      navigator.push(
        MaterialPageRoute(
          builder: (routeContext) => BlocProvider(
            create: (blocContext) => RoomChatBloc(roomRepo),
            child: RoomChatScreen(room: room),
          ),
        ),
      );
    } catch (e) {
      print('[SearchScreen] Create chat failed: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to start chat: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.teal[900]!.withValues(alpha: 0.05),
              const Color(0xFF0A0A0C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled search page title
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 16.0, right: 20.0),
                child: Text(
                  'Discovery',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Glass Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: _tabController.index == 0 ? 'Search discussions, public threads...' : 'Search people by name, email...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13, fontFamily: 'Inter'),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.4), size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Premium Segmented Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.amber[700],
                labelColor: Colors.amber[700],
                unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
                labelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 13.5, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 13.5),
                tabs: const [
                  Tab(text: 'Public Threads'),
                  Tab(text: 'Find People'),
                ],
              ),
              const SizedBox(height: 8),

              // Active state or list rendering
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPostListTab(),
                          _buildUserListTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostListTab() {
    if (_postResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.forum_outlined,
        title: _activeQuery.isEmpty ? 'No recommended threads' : 'No threads match "$_activeQuery"',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        final item = _postResults[index];
        final type = item['type'] ?? 'thread';
        final name = item['name'] ?? 'Untitled Room';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.15),
                ),
                child: Icon(
                  type == 'ai' ? Icons.auto_awesome : Icons.groups_rounded,
                  color: Colors.tealAccent,
                  size: 20,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Public discussion thread • Active',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontFamily: 'Inter', fontSize: 11.5),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
              onTap: () {
                // Navigate into thread
                final room = Room(
                  id: item['id'],
                  name: name,
                  type: type == 'ai' ? RoomType.ai : (type == 'private' ? RoomType.private : RoomType.thread),
                  status: RoomStatus.open,
                  ownerId: item['owner_id'] ?? '',
                  createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
                  isPublic: item['is_public'] ?? true,
                );
                
                final roomRepo = RepositoryProvider.of<RoomRepository>(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (routeContext) => BlocProvider(
                      create: (blocContext) => RoomChatBloc(roomRepo),
                      child: RoomChatScreen(room: room),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListTab() {
    if (_userResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: _activeQuery.isEmpty ? 'No users listed' : 'No users match "$_activeQuery"',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        final fullName = user['full_name'] ?? 'Anonymous User';
        final email = user['email'] ?? '';
        final avatarUrl = user['avatar_url'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white60) : null,
              ),
              title: Text(
                fullName,
                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Text(
                email,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontFamily: 'Inter', fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber[800]!.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.forum_outlined, color: Colors.amber[500], size: 18),
              ),
              onTap: () => _initiateChat(context, user['id'], fullName),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Inter', fontSize: 13),
          ),
        ],
      ),
    );
  }
}
