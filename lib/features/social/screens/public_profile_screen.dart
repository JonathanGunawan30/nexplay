import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../models/game_model.dart';
import '../../games/providers/game_provider.dart';
import '../../games/screens/game_detail_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/social_provider.dart';

class PublicProfileScreen extends StatelessWidget {
  final UserModel user;
  const PublicProfileScreen({super.key, required this.user});

  void _showUnfriendDialog(BuildContext context, UserModel currentUser, SocialProvider socialProvider) {
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
    final gameProvider = Provider.of<GameProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final socialProvider = Provider.of<SocialProvider>(context);
    
    final currentUser = authProvider.userModel;
    final bool isFriend = currentUser?.friends.contains(user.uid) ?? false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentColor = Colors.indigoAccent;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (isFriend && currentUser != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Unfriend',
                      onPressed: () => _showUnfriendDialog(context, currentUser, socialProvider),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  user.selectedWallpaper.isNotEmpty 
                      ? Image.asset(user.selectedWallpaper, fit: BoxFit.cover)
                      : Container(color: bgColor),
                  if (user.selectedWallpaper.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            bgColor.withOpacity(0.8),
                            bgColor,
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: bgColor, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: user.photoURL.isNotEmpty
                              ? Image.network(user.photoURL, fit: BoxFit.cover)
                              : Container(
                                  color: accentColor.withOpacity(0.1),
                                  child: Icon(Icons.person, size: 70, color: accentColor),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  if (user.bio.isNotEmpty)
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: textColor.withOpacity(0.6), height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 32),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Friends', user.friends.length.toString(), accentColor, textColor),
                        Container(width: 1, height: 30, color: textColor.withOpacity(0.1)),
                        StreamBuilder<List<GameModel>>(
                          stream: gameProvider.getUserGames(user.uid),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.length ?? 0;
                            return _buildStatItem('Games', count.toString(), accentColor, textColor);
                          }
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Game Diary",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                      ),
                      Icon(Icons.auto_awesome_mosaic_rounded, color: accentColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          StreamBuilder<List<GameModel>>(
            stream: gameProvider.getUserGames(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())));
              }
              final games = snapshot.data ?? [];
              if (games.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.sports_esports_outlined, size: 64, color: textColor.withOpacity(0.05)),
                          const SizedBox(height: 16),
                          Text('No gaming history shared yet', style: TextStyle(color: textColor.withOpacity(0.3), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      return _DynamicGameCard(game: game, isDark: isDark, accentColor: accentColor, textColor: textColor);
                    },
                    childCount: games.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color accentColor, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _DynamicGameCard extends StatelessWidget {
  final GameModel game;
  final bool isDark;
  final Color accentColor;
  final Color textColor;

  const _DynamicGameCard({required this.game, required this.isDark, required this.accentColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GameDetailScreen(game: game))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              game.imageUrl.isNotEmpty
                  ? Image.network(game.imageUrl, fit: BoxFit.cover)
                  : Container(color: accentColor.withOpacity(0.1)),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // Rating Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        game.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),

              // Info Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        game.genre.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.platform,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
