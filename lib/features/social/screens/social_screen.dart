import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../providers/social_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'chat_screen.dart';
import 'public_profile_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final results = await socialProvider.searchUsers(query, authProvider.user?.uid ?? '');
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final socialProvider = Provider.of<SocialProvider>(context);
    final currentUser = authProvider.userModel;

    if (currentUser == null) return const Center(child: CircularProgressIndicator());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentColor = Colors.indigoAccent;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Community', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 26)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    icon: Icon(Icons.person_search_rounded, color: accentColor),
                    hintText: 'Search players...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            if (_searchResults.isNotEmpty || _isSearching) ...[
              _buildSectionTitle('Search Results', textColor),
              if (_isSearching)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _UserTile(user: _searchResults[index], currentUser: currentUser, socialProvider: socialProvider);
                  },
                ),
              const Divider(indent: 24, endIndent: 24, height: 40),
            ],

            // Pending Requests
            StreamBuilder<List<UserModel>>(
              stream: socialProvider.getReceivedRequestsStream(currentUser.receivedRequests),
              builder: (context, snapshot) {
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Friend Requests', textColor),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _RequestTile(user: requests[index], currentUser: currentUser, socialProvider: socialProvider);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            // Friends List
            _buildSectionTitle('Your Friends', textColor),
            StreamBuilder<List<UserModel>>(
              stream: socialProvider.getFriendsStream(currentUser.friends),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                final friends = snapshot.data ?? [];
                if (friends.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: textColor.withOpacity(0.1)),
                          const SizedBox(height: 12),
                          Text('No friends yet. Start exploring!', style: TextStyle(color: textColor.withOpacity(0.3), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return _FriendTile(user: friends[index], currentUser: currentUser, socialProvider: socialProvider);
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.2)),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final SocialProvider socialProvider;

  const _UserTile({required this.user, required this.currentUser, required this.socialProvider});

  @override
  Widget build(BuildContext context) {
    final bool isFriend = currentUser.friends.contains(user.uid);
    final bool isSent = currentUser.sentRequests.contains(user.uid);
    final bool isReceived = currentUser.receivedRequests.contains(user.uid);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PublicProfileScreen(user: user))),
        child: CircleAvatar(
          radius: 26,
          backgroundImage: user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : null,
          child: user.photoURL.isEmpty ? const Icon(Icons.person) : null,
        ),
      ),
      title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(user.bio.isNotEmpty ? user.bio : 'Level 1 Gamer', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isFriend
          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
          : (isSent 
              ? Text('Pending', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))
              : (isReceived 
                  ? const Icon(Icons.info_outline_rounded, color: Colors.orange)
                  : ElevatedButton(
                      onPressed: () => socialProvider.sendFriendRequest(currentUser.uid, user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                    ))),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final SocialProvider socialProvider;

  const _RequestTile({required this.user, required this.currentUser, required this.socialProvider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PublicProfileScreen(user: user))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : null,
        child: user.photoURL.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('wants to be your friend'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => socialProvider.rejectFriendRequest(currentUser.uid, user.uid),
            icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
          ),
          IconButton(
            onPressed: () => socialProvider.acceptFriendRequest(currentUser.uid, user.uid),
            icon: const Icon(Icons.check_rounded, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final SocialProvider socialProvider;

  const _FriendTile({required this.user, required this.currentUser, required this.socialProvider});

  void _showUnfriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Unfriend', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove ${user.displayName} from your friends?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              socialProvider.unfriend(currentUser.uid, user.uid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(friend: user))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PublicProfileScreen(user: user))),
        child: CircleAvatar(
          radius: 26,
          backgroundImage: user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : null,
          child: user.photoURL.isEmpty ? const Icon(Icons.person) : null,
        ),
      ),
      title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Tap to chat', style: TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showUnfriendDialog(context),
            icon: Icon(Icons.person_remove_rounded, color: Colors.redAccent.withOpacity(0.5), size: 20),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
