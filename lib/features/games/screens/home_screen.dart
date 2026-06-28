import 'dart:async';
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
import 'all_games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Banner Carousel variables
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final List<String> _banners = [
    'assets/banner/minecraft-banner.jpg',
    'assets/banner/nexplay-summer-sale.png',
    'assets/banner/nexplay-play-more-1.png',
    'assets/banner/nexplay-play-more-2.png'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.65, curve: Curves.easeOutQuart)));
    _animationController.forward();

    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final premiumGameProvider = Provider.of<PremiumGameProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentColor = Colors.indigoAccent;
    final String photoURL = authProvider.userModel?.photoURL ?? authProvider.user?.photoURL ?? '';

    // Split games into Paid and Free
    final paidGames = premiumGameProvider.games.where((g) => g.price > 0).toList();
    final freeGames = premiumGameProvider.games.where((g) => g.price == 0).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with Search and Profile
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AllGamesScreen()),
                              );
                            },
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded, color: accentColor),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Search all games...',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.3),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accentColor.withOpacity(0.2), width: 2),
                            ),
                            child: ClipOval(
                              child: photoURL.isNotEmpty
                                  ? Image.network(photoURL, fit: BoxFit.cover)
                                  : Icon(Icons.person, color: accentColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Banner Carousel Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1170 / 500,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                                itemCount: _banners.length,
                                itemBuilder: (context, index) {
                                  return Image.asset(
                                    _banners[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_banners.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: _currentBannerIndex == index ? 24 : 6,
                              decoration: BoxDecoration(
                                color: _currentBannerIndex == index ? accentColor : accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // Paid Games Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Must Play (Paid)', textColor),
                        Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 240,
                    child: premiumGameProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: paidGames.length,
                            itemBuilder: (context, index) {
                              return _PremiumGameCard(game: paidGames[index], isDark: isDark);
                            },
                          ),
                  ),
                ),

                // Your Diary Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Your Diary', textColor),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.add_rounded,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGameScreen())),
                              accentColor: accentColor,
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FullDiaryScreen())),
                              style: TextButton.styleFrom(
                                foregroundColor: accentColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: StreamBuilder<List<GameModel>>(
                      stream: gameProvider.getUserGames(authProvider.user?.uid ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                        }
                        final games = snapshot.data ?? [];
                        if (games.isEmpty) {
                          return _buildEmptyDiary(textColor);
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return _MiniGameCard(game: game, isDark: isDark);
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Free Games Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Trending Now (Free)', textColor),
                        Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 20),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: premiumGameProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: freeGames.length,
                            itemBuilder: (context, index) {
                              final game = freeGames[index];
                              return _MiniPremiumGameCard(game: game, isDark: isDark);
                            },
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap, required Color accentColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accentColor, size: 24),
      ),
    );
  }

  Widget _buildEmptyDiary(Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports_outlined, size: 40, color: textColor.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              'No games recorded yet.',
              style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
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
              game.imageUrl.startsWith('assets/')
                  ? Image.asset(game.imageUrl, fit: BoxFit.cover)
                  : Image.network(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Text(
                    game.price == 0 ? 'FREE' : '\$${game.price}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.genre.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.0,
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
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              game.imageUrl.isNotEmpty
                  ? (game.imageUrl.startsWith('assets/')
                      ? Image.asset(game.imageUrl, fit: BoxFit.cover)
                      : Image.network(
                          game.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                        ))
                  : Container(color: Colors.indigoAccent.withOpacity(0.1)),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        game.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _MiniPremiumGameCard extends StatelessWidget {
  final PremiumGameModel game;
  final bool isDark;
  const _MiniPremiumGameCard({required this.game, required this.isDark});

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
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(game.imageUrl, fit: BoxFit.cover),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),

              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
