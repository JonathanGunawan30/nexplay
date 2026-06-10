import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'full_diary_screen.dart';
import 'all_games_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../social/screens/social_screen.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AllGamesScreen(),
    const SocialScreen(),
    const FullDiaryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Colors.indigoAccent;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    
    final bool hasPendingRequests = authProvider.userModel?.receivedRequests.isNotEmpty ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  alignment: _getAlignment(_currentIndex),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 5,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavIcon(0, Icons.home_rounded),
                    _buildNavIcon(1, Icons.explore_rounded),
                    _buildNavIcon(2, Icons.people_rounded, hasBadge: hasPendingRequests),
                    _buildNavIcon(3, Icons.sports_esports_rounded),
                    _buildNavIcon(4, Icons.person_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0: return Alignment.centerLeft;
      case 1: return const Alignment(-0.5, 0);
      case 2: return Alignment.center;
      case 3: return const Alignment(0.5, 0);
      case 4: return Alignment.centerRight;
      default: return Alignment.centerLeft;
    }
  }

  Widget _buildNavIcon(int index, IconData icon, {bool hasBadge = false}) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Colors.indigoAccent;
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 26,
              ),
              if (hasBadge)
                Positioned(
                  top: 15,
                  right: 18,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
