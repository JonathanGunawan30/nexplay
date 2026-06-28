import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _previewBytes;
  ThemeMode? _localThemeMode; // Tambahkan ini

  final List<String> _wallpapers = [
    'assets/wallpaper/wall-batman.png',
    'assets/wallpaper/wall-bo.png',
    'assets/wallpaper/wall-cod.jpg',
    'assets/wallpaper/wall-diablo.png',
    'assets/wallpaper/wall-fl.jpg',
    'assets/wallpaper/wall-forza.jpg',
    'assets/wallpaper/wall-g.png',
    'assets/wallpaper/wall-halo.png',
    'assets/wallpaper/wall-ij.png',
    'assets/wallpaper/wall-mf.png',
    'assets/wallpaper/wall-rs.jpg',
    'assets/wallpaper/wall-ufc.jpg',
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.userModel?.displayName ?? authProvider.user?.displayName ?? '';
    _bioController.text = authProvider.userModel?.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Sinkronisasi local mode dengan global mode hanya jika belum diatur secara lokal
    _localThemeMode ??= themeProvider.themeMode;

    String photoURL = '';
    if (authProvider.userModel != null && authProvider.userModel!.photoURL.isNotEmpty) {
      photoURL = authProvider.userModel!.photoURL;
    } else if (authProvider.user != null && authProvider.user!.photoURL != null) {
      photoURL = authProvider.user!.photoURL!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = Colors.indigoAccent;
    final wallpaper = authProvider.userModel?.selectedWallpaper ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Navigator.canPop(context) 
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                : null,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    tooltip: 'Logout',
                    onPressed: () {
                      authProvider.signOut();
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  wallpaper.isNotEmpty 
                      ? Image.asset(wallpaper, fit: BoxFit.cover)
                      : Container(color: Theme.of(context).scaffoldBackgroundColor),
                  if (wallpaper.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                            Theme.of(context).scaffoldBackgroundColor,
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
                      child: GestureDetector(
                        onTap: () async {
                          final image = await profileProvider.pickImage();
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              _selectedImage = image;
                              _previewBytes = bytes;
                            });
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: ClipOval(
                                child: _previewBytes != null
                                    ? Image.memory(_previewBytes!, fit: BoxFit.cover)
                                    : (photoURL.isNotEmpty
                                        ? Image.network(
                                            photoURL,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: accentColor.withOpacity(0.1),
                                              child: Icon(Icons.person, size: 70, color: accentColor),
                                            ),
                                          )
                                        : Container(
                                            color: accentColor.withOpacity(0.1),
                                            child: Icon(Icons.person, size: 70, color: accentColor),
                                          )),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _nameController.text.isNotEmpty ? _nameController.text : 'Gamer Name',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.email ?? 'player@nexplay.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  _buildModernField(
                    controller: _nameController,
                    label: 'Display Name',
                    hint: 'Your player name',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 24),

                  _buildModernField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'A bit about your gaming journey...',
                    icon: Icons.auto_awesome_outlined,
                    maxLines: 3,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Appearance', textColor),
                  const SizedBox(height: 16),
                  
                  Container(
                    height: 70,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: _localThemeMode == ThemeMode.light 
                              ? Alignment.centerLeft 
                              : (_localThemeMode == ThemeMode.system ? Alignment.center : Alignment.centerRight),
                          child: FractionallySizedBox(
                            widthFactor: 1 / 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? accentColor : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _buildThemeButton('Light', Icons.light_mode_rounded, _localThemeMode == ThemeMode.light, () {
                              setState(() => _localThemeMode = ThemeMode.light);
                              Future.delayed(const Duration(milliseconds: 300), () => themeProvider.setThemeMode(ThemeMode.light));
                            }, isDark),
                            _buildThemeButton('System', Icons.brightness_auto_rounded, _localThemeMode == ThemeMode.system, () {
                              setState(() => _localThemeMode = ThemeMode.system);
                              Future.delayed(const Duration(milliseconds: 300), () => themeProvider.setThemeMode(ThemeMode.system));
                            }, isDark),
                            _buildThemeButton('Dark', Icons.dark_mode_rounded, _localThemeMode == ThemeMode.dark, () {
                              setState(() => _localThemeMode = ThemeMode.dark);
                              Future.delayed(const Duration(milliseconds: 300), () => themeProvider.setThemeMode(ThemeMode.dark));
                            }, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Profile Wallpaper', textColor),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _wallpapers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final bool isNone = authProvider.userModel?.selectedWallpaper.isEmpty ?? true;
                          return GestureDetector(
                            onTap: () => profileProvider.updateWallpaper(''),
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isNone ? accentColor : (isDark ? Colors.white10 : Colors.black.withOpacity(0.1)),
                                  width: isNone ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.block_rounded, color: isNone ? accentColor : textColor.withOpacity(0.3)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'None',
                                    style: TextStyle(
                                      color: isNone ? accentColor : textColor.withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final wp = _wallpapers[index - 1];
                        final bool isSelected = authProvider.userModel?.selectedWallpaper == wp;
                        return GestureDetector(
                          onTap: () => profileProvider.updateWallpaper(wp),
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? accentColor : Colors.transparent,
                                width: 3,
                              ),
                              image: DecorationImage(image: AssetImage(wp), fit: BoxFit.cover),
                              boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
                            ),
                            child: isSelected 
                                ? Center(child: Icon(Icons.check_circle_rounded, color: accentColor, size: 40))
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (profileProvider.isLoading)
                    Center(child: CircularProgressIndicator(color: accentColor))
                  else
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await profileProvider.updateProfile(
                            newName: _nameController.text,
                            newBio: _bioController.text,
                            imageFile: _selectedImage,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Profile updated successfully!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // ponytail: Display Transaction History section
                  _buildTransactionHistory(context, authProvider, textColor, cardColor, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildThemeButton(String title, IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Memberikan feedback haptic sederhana atau jeda mikro agar animasi mulai duluan
          onTap();
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? (isDark ? Colors.white : Colors.indigoAccent) 
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected 
                      ? (isDark ? Colors.white : Colors.indigoAccent) 
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.indigoAccent : Colors.indigo,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
            filled: true,
            fillColor: cardColor,
            prefixIcon: Icon(icon, color: Colors.indigoAccent.withOpacity(0.7)),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.indigoAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ponytail: StreamBuilder to display transactions list from Firestore inline with direct Cloudinary PDF invoice links
  Widget _buildTransactionHistory(
    BuildContext context,
    AuthProvider authProvider,
    Color textColor,
    Color cardColor,
    bool isDark,
  ) {
    if (authProvider.user == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Transaction History', textColor),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(authProvider.user!.uid)
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading history',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.indigoAccent));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Center(
                  child: Text(
                    'No purchases recorded yet.',
                    style: TextStyle(
                      color: textColor.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = docs[index].data() as Map<String, dynamic>;
                final timestamp = tx['timestamp'] as Timestamp?;
                final dateStr = timestamp != null
                    ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                    : '-';
                final amount = tx['amount'] as double? ?? 0.0;
                final currency = tx['currency'] as String? ?? 'USD';
                final pdfUrl = tx['pdf_url'] as String? ?? '';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.indigoAccent, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['game_title'] ?? 'Game Purchase',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: textColor.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (pdfUrl.isNotEmpty && pdfUrl != 'success_no_url') ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(pdfUrl);
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  debugPrint('Error launching invoice URL: $e');
                                }
                              },
                              child: Text(
                                'Invoice PDF',
                                style: TextStyle(
                                  color: Colors.indigoAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
