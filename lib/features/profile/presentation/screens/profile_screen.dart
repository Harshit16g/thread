import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/events/profile_event.dart';
import '../bloc/states/profile_state.dart';
import 'profile_edit_screen.dart';
import '../../../../core/services/ideas_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<SavedIdea> _savedIdeas = [];

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(userId));
    }
    _loadSavedIdeas();
  }

  Future<void> _loadSavedIdeas() async {
    final ideas = await IdeasService.getIdeas();
    if (mounted) {
      setState(() {
        _savedIdeas = ideas;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomLeft,
            radius: 1.6,
            colors: [
              Colors.amber[900]!.withValues(alpha: 0.05),
              const Color(0xFF0A0A0C),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.amber));
              }

              if (state.profile == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 60, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text(
                        'No profile found',
                        style: TextStyle(color: Colors.white38, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final userId = Supabase.instance.client.auth.currentUser?.id;
                          if (userId != null) {
                            context.read<ProfileBloc>().add(ProfileLoadRequested(userId));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final profile = state.profile!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Stunning Page Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'My Profile',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar Stack with animated neon gradient borders
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 114, height: 114,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orangeAccent, Colors.redAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Container(
                            width: 108, height: 108,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0A0A0C),
                            ),
                          ),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[900],
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? const Icon(Icons.person, size: 48, color: Colors.white60)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Name
                    Text(
                      profile.fullName ?? 'No Name',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // High-End Statistics grid panel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Discussions', '12', Colors.tealAccent),
                        _buildStatItem('Active Bots', '6', Colors.amberAccent),
                        _buildStatItem('Proposals', '8', Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Bio Card Section
                    GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.chrome_reader_mode_outlined, color: Colors.amber, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'About Me & Bio',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              profile.bio ?? 'No bio has been added to this profile yet. Describe your agricultural or business experience!',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.6),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Card Section
                    GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                            child: const Icon(Icons.phone_outlined, color: Colors.white70, size: 18),
                          ),
                          title: const Text(
                            'Phone Listing',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            profile.phoneNumber ?? 'Not verified',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                          ),
                        ),
                      ),
                    ),

                    // Workspace Ideas Ledger Board
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Workspace Ideas Ledger',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white38, size: 18),
                            onPressed: _loadSavedIdeas,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_savedIdeas.isEmpty)
                      GlassContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.star_outline_rounded, color: Colors.white24, size: 36),
                                const SizedBox(height: 10),
                                const Text(
                                  'Your Ledger is empty',
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white54, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Long-press message bubbles to bookmark important ideas here',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _savedIdeas.length,
                        itemBuilder: (context, index) {
                          final idea = _savedIdeas[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.04)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ExpansionTile(
                                collapsedIconColor: Colors.amber,
                                iconColor: Colors.amberAccent,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 16),
                                ),
                                title: Text(
                                  idea.source,
                                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Saved on ${idea.savedAt.toIso8601String().split('T')[0]}',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 10.5, color: Colors.white.withOpacity(0.35)),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          idea.content,
                                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70, height: 1.45),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () async {
                                                await IdeasService.deleteIdea(idea.id);
                                                _loadSavedIdeas();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Colors.redAccent,
                                                    content: Text('Idea deleted from Ledger!'),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.redAccent),
                                              label: const Text('Delete', style: TextStyle(fontFamily: 'Outfit', color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 28),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileEditScreen(profile: profile),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text(
                          'Configure Details',
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.amber[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Logout Button with premium neon-red outline
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF161618),
                              title: const Text('Logout', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
                              content: const Text(
                                'Are you sure you want to end your active workspace session?',
                                style: TextStyle(color: Colors.white54, fontFamily: 'Inter'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Keep Working', style: TextStyle(fontFamily: 'Inter')),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<ProfileBloc>().add(ProfileLogoutRequested());
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontFamily: 'Inter')),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text(
                          'End Workspace Session',
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontFamily: 'Inter',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
