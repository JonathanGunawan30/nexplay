import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

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
    
    String photoURL = '';
    if (authProvider.userModel != null && authProvider.userModel!.photoURL.isNotEmpty) {
      photoURL = authProvider.userModel!.photoURL;
    } else if (authProvider.user != null && authProvider.user!.photoURL != null) {
      photoURL = authProvider.user!.photoURL!;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
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
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: ClipOval(
                        child: _previewBytes != null
                            ? Image.memory(_previewBytes!, fit: BoxFit.cover)
                            : (photoURL.isNotEmpty
                                ? Image.network(
                                    photoURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.indigo.withAlpha(30), child: const Icon(Icons.person, size: 70, color: Colors.indigo)),
                                  )
                                : Container(color: Colors.indigo.withAlpha(30), child: const Icon(Icons.person, size: 70, color: Colors.indigo))),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 10),
            _buildTextField(controller: _nameController, hint: 'Enter your name', icon: Icons.person_outline_rounded),
            const SizedBox(height: 24),
            _buildFieldLabel('Bio'),
            const SizedBox(height: 10),
            _buildTextField(controller: _bioController, hint: 'Tell us a bit about yourself...', icon: Icons.info_outline_rounded, maxLines: 3),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.indigo),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
      ),
    );
  }
}
