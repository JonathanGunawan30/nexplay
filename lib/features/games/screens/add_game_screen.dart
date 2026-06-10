import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _developerController = TextEditingController();
  final _yearController = TextEditingController();
  final _platformController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _rating = 0;
  XFile? _selectedImage;
  Uint8List? _previewBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _developerController.dispose();
    _yearController.dispose();
    _platformController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = Colors.indigoAccent;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.white70,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () async {
                  final image = await gameProvider.pickCoverImage();
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _selectedImage = image;
                      _previewBytes = bytes;
                    });
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _previewBytes != null
                        ? Image.memory(_previewBytes!, fit: BoxFit.cover)
                        : Container(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDark ? accentColor.withOpacity(0.1) : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.black : accentColor).withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 48,
                                      color: isDark ? accentColor : Colors.indigo.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'UPLOAD COVER IMAGE',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.indigo.shade900,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Click here to select a file',
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.indigo.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    if (_previewBytes != null)
                      Positioned(
                        bottom: 40,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.indigoAccent : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: isDark ? Colors.white : Colors.indigo.shade100,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Change Cover',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.indigo.shade900,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture your gaming memories in your personal diary.',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildModernField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'What game did you play?',
                      icon: Icons.sports_esports_outlined,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernField(
                            controller: _genreController,
                            label: 'Genre',
                            hint: 'RPG, Action...',
                            icon: Icons.category_outlined,
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernField(
                            controller: _yearController,
                            label: 'Release',
                            hint: '2024',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildRatingSelector(accentColor, textColor),
                    const SizedBox(height: 24),

                    _buildModernField(
                      controller: _developerController,
                      label: 'Developer',
                      hint: 'Studio name',
                      icon: Icons.business_outlined,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 20),

                    _buildModernField(
                      controller: _platformController,
                      label: 'Platform',
                      hint: 'PS5, PC, Switch...',
                      icon: Icons.devices_outlined,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 20),

                    _buildModernField(
                      controller: _descriptionController,
                      label: 'Notes',
                      hint: 'Your thoughts on this game...',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    if (gameProvider.isLoading)
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
                            if (_formKey.currentState!.validate()) {
                              final success = await gameProvider.addGame(
                                userId: authProvider.user!.uid,
                                title: _titleController.text,
                                genre: _genreController.text,
                                rating: _rating,
                                developer: _developerController.text,
                                releaseYear: _yearController.text,
                                platform: _platformController.text,
                                description: _descriptionController.text,
                                imageFile: _selectedImage,
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Entry added successfully!'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text(
                            'Save Entry',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    TextInputType keyboardType = TextInputType.text,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
        ),
      ],
    );
  }

  Widget _buildRatingSelector(Color accentColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigoAccent,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  double starRating = _rating - index;
                  IconData iconData;
                  if (starRating >= 1) {
                    iconData = Icons.star_rounded;
                  } else if (starRating >= 0.5) {
                    iconData = Icons.star_half_rounded;
                  } else {
                    iconData = Icons.star_outline_rounded;
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = (index + 1).toDouble();
                      });
                    },
                    child: Icon(
                      iconData,
                      size: 42,
                      color: starRating > 0 ? accentColor : textColor.withOpacity(0.2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: accentColor,
                  inactiveTrackColor: accentColor.withOpacity(0.1),
                  thumbColor: Colors.white,
                  overlayColor: accentColor.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                ),
                child: Slider(
                  value: _rating,
                  min: 0,
                  max: 5,
                  divisions: 50,
                  onChanged: (value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
