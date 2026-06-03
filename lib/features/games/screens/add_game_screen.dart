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
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final inputColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add to Diary',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
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
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      image: _previewBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_previewBytes!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _previewBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 50, color: Colors.indigo.withAlpha(100)),
                              const SizedBox(height: 8),
                              Text('Upload Cover Image', style: TextStyle(color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8))),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildLabel('Game Title', isDark),
              _buildTextField(_titleController, 'Enter game title', Icons.title_rounded, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 20),
              _buildLabel('Genre', isDark),
              _buildTextField(_genreController, 'Enter game genre', Icons.category_rounded, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 20),
              _buildLabel('Rating (0-5)', isDark),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 50,
                label: _rating.toStringAsFixed(1),
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 20),
              _buildLabel('Developer', isDark),
              _buildTextField(_developerController, 'Enter developer name', Icons.business_rounded, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 20),
              _buildLabel('Release Year', isDark),
              _buildTextField(_yearController, 'Enter release year', Icons.calendar_today_rounded, keyboardType: TextInputType.number, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 20),
              _buildLabel('Platform', isDark),
              _buildTextField(_platformController, 'Enter target platforms', Icons.videogame_asset_rounded, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 20),
              _buildLabel('Description', isDark),
              _buildTextField(_descriptionController, 'Write something about the game...', Icons.description_rounded, maxLines: 3, isDark: isDark, inputColor: inputColor),
              const SizedBox(height: 40),
              if (gameProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.indigo))
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
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
                            const SnackBar(content: Text('Game added to diary!'), backgroundColor: Colors.green),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save to Diary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, required bool isDark, required Color inputColor}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        filled: true,
        fillColor: inputColor,
        prefixIcon: Icon(icon, color: Colors.indigo),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
      ),
    );
  }
}
