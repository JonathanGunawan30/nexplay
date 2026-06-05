import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/game_provider.dart';
import '../screens/add_game_screen.dart';
import '../../../models/game_model.dart';
import '../../../models/premium_game_model.dart';
import '../providers/premium_game_provider.dart';
import 'game_detail_screen.dart';
import 'full_diary_screen.dart';
import 'premium_game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final premiumGameProvider = Provider.of<PremiumGameProvider>(context);
    
    final String photoURL = authProvider.userModel?.photoURL ?? authProvider.user?.photoURL ?? '';
    final String displayName = authProvider.userModel?.displayName ?? authProvider.user?.displayName ?? 'Player';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Discover', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.indigo.withAlpha(50), width: 2)),
              child: ClipOval(
                child: photoURL.isNotEmpty
                    ? Image.network(
                        photoURL,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 20, color: Colors.indigo),
                      )
                    : const Icon(Icons.person, size: 20, color: Colors.indigo),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text('Welcome back,', style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(displayName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor)),
                      if (authProvider.userModel?.bio.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(authProvider.userModel!.bio, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 40),
                      Text('Premium Games', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: premiumGameProvider.isLoading && premiumGameProvider.games.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: premiumGameProvider.games.length,
                          itemBuilder: (context, index) {
                            final premiumGame = premiumGameProvider.games[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: _PremiumGameCard(game: premiumGame, isDark: isDark),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Game Diary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGameScreen())),
                                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.indigo),
                                tooltip: 'Add Entry',
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FullDiaryScreen())),
                                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                                child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: StreamBuilder<List<GameModel>>(
                    stream: gameProvider.getUserGames(authProvider.user?.uid ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                      }
                      final games = snapshot.data ?? [];
                      if (games.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_esports_outlined, size: 48, color: const Color(0xFF94A3B8).withAlpha(100)),
                              const SizedBox(height: 12),
                              const Text('Your diary is empty.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: _MiniGameCard(game: game, isDark: isDark),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => authProvider.signOut(),
        backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFF1E293B),
        icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
        label: const Text('Logout', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PremiumGameCard extends StatelessWidget {
  final PremiumGameModel game;
  final bool isDark;
  const _PremiumGameCard({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumGameDetailScreen(game: game),
          ),
        );
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(50),
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                      Colors.black.withAlpha(220),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    game.price == 0 ? 'Free' : '\$${game.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.genre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade300,
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

class _MiniGameCard extends StatelessWidget {
  final GameModel game;
  final bool isDark;
  const _MiniGameCard({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailScreen(game: game),
          ),
        );
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              game.imageUrl.isNotEmpty
                  ? Image.network(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 30)),
                    )
                  : Container(color: Colors.grey.shade200, child: const Icon(Icons.sports_esports, color: Colors.grey, size: 30)),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(100),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withAlpha(100), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(game.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
