import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/premium_game_provider.dart';
import '../../../models/premium_game_model.dart';
import 'premium_game_detail_screen.dart';

class AllGamesScreen extends StatefulWidget {
  final String? initialQuery;
  const AllGamesScreen({super.key, this.initialQuery});

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumGameProvider = Provider.of<PremiumGameProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentColor = Colors.indigoAccent;

    final filteredGames = premiumGameProvider.games.where((game) {
      return game.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             game.genre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explore Games',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: true,
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  icon: Icon(Icons.search_rounded, color: accentColor),
                  hintText: 'Search title or genre...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textColor.withOpacity(0.3)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredGames.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: textColor.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(
                          'No games found',
                          style: TextStyle(color: textColor.withOpacity(0.3), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      return _CompactGameCard(game: game, isDark: isDark, accentColor: accentColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompactGameCard extends StatelessWidget {
  final PremiumGameModel game;
  final bool isDark;
  final Color accentColor;

  const _CompactGameCard({required this.game, required this.isDark, required this.accentColor});

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    game.price == 0 ? 'FREE' : '\$${game.price}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      game.genre.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
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
