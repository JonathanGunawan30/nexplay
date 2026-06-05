import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    String photoURL = '';
    if (authProvider.userModel != null && authProvider.userModel!.photoURL.isNotEmpty) {
      photoURL = authProvider.userModel!.photoURL;
    } else if (authProvider.user != null && authProvider.user!.photoURL != null) {
      photoURL = authProvider.user!.photoURL!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
    final inputColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final wallpaper = authProvider.userModel?.selectedWallpaper ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withAlpha(20),
                    image: wallpaper.isNotEmpty 
                      ? DecorationImage(image: AssetImage(wallpaper), fit: BoxFit.cover) 
                      : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(80),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: -50,
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
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 15)],
                            ),
                            child: ClipOval(
                              child: _previewBytes != null
                                  ? Image.memory(_previewBytes!, fit: BoxFit.cover)
                                  : (photoURL.isNotEmpty
                                      ? Image.network(
                                          photoURL,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.indigo.withAlpha(30), child: const Icon(Icons.person, size: 60, color: Colors.indigo)),
                                        )
                                      : Container(color: Colors.indigo.withAlpha(30), child: const Icon(Icons.person, size: 60, color: Colors.indigo))),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2)),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  _buildFieldLabel('Full Name'),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _nameController, hint: 'Enter your name', icon: Icons.person_outline_rounded, isDark: isDark, inputColor: inputColor),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Bio'),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _bioController, hint: 'Tell us a bit about yourself...', icon: Icons.info_outline_rounded, maxLines: 3, isDark: isDark, inputColor: inputColor),
                  const SizedBox(height: 32),
                  _buildFieldLabel('App Mode'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        _ThemeOption(
                          title: 'Light',
                          icon: Icons.light_mode_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.light,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                          isDark: isDark,
                        ),
                        Container(width: 1, height: 40, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        _ThemeOption(
                          title: 'System',
                          icon: Icons.brightness_auto_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.system,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                          isDark: isDark,
                        ),
                        Container(width: 1, height: 40, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        _ThemeOption(
                          title: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.dark,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFieldLabel('Profile Theme (Header)'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _wallpapers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final bool isNone = authProvider.userModel?.selectedWallpaper.isEmpty ?? true;
                          return GestureDetector(
                            onTap: () => profileProvider.updateWallpaper(''),
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: inputColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isNone ? Colors.indigo : (isDark ? Colors.grey.shade800 : Colors.grey.shade200), width: isNone ? 2 : 1),
                              ),
                              child: Center(child: Text('Default', style: TextStyle(color: isNone ? Colors.indigo : secondaryTextColor, fontWeight: FontWeight.bold))),
                            ),
                          );
                        }
                        final wp = _wallpapers[index - 1];
                        final bool isSelected = authProvider.userModel?.selectedWallpaper == wp;
                        return GestureDetector(
                          onTap: () => profileProvider.updateWallpaper(wp),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? Colors.indigo : Colors.transparent, width: 2),
                              image: DecorationImage(image: AssetImage(wp), fit: BoxFit.cover),
                            ),
                            child: isSelected ? const Align(alignment: Alignment.topRight, child: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.indigo, size: 20))) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (profileProvider.isLoading)
                    const CircularProgressIndicator(color: Colors.indigo)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          await profileProvider.updateProfile(
                            newName: _nameController.text,
                            newBio: _bioController.text,
                            imageFile: _selectedImage,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Profile updated successfully!'), backgroundColor: Colors.indigo, behavior: SnackBarBehavior.floating));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1, required bool isDark, required Color inputColor}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        filled: true,
        fillColor: inputColor,
        prefixIcon: Icon(icon, color: Colors.indigo),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.indigo : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.indigo : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
