import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/services/image_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final ImageService _imageService = ImageService();

  File? selectedProfileImage;
  String? currentProfilePicture;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          usernameController.text = userData['username'] ?? '';
          bioController.text = userData['bio'] ?? '';
          currentProfilePicture = userData['profilePicture'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final images = await _imageService.pickPostImages();
      if (images.isNotEmpty) {
        setState(() {
          selectedProfileImage = images.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _saveProfile() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    //validate username
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    //check username length
    if (usernameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be at least 3 characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    //check for special characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username can only contain letters, numbers, and underscores'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      String? profilePictureUrl = currentProfilePicture;

      //upload new profile picture if selected
      if (selectedProfileImage != null) {
        final urls = await _imageService.uploadPostImages(
          [selectedProfileImage!],
          'profile_${currentUser.uid}',
        );
        profilePictureUrl = urls.first;
      }

      //update Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .update({
        'username': usernameController.text.trim(),
        'bio': bioController.text.trim(),
        if (profilePictureUrl != null) 'profilePicture': profilePictureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (isSaving) return false;

    //check if there are unsaved changes
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return true;

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) return true;

    final userData = userDoc.data() as Map<String, dynamic>;
    final hasChanges = usernameController.text.trim() != (userData['username'] ?? '') ||
        bioController.text.trim() != (userData['bio'] ?? '') ||
        selectedProfileImage != null;

    if (!hasChanges) return true;

    //show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
          actions: [
            if (isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _saveProfile,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Section
              GestureDetector(
                onTap: isSaving ? null : _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: selectedProfileImage != null
                            ? Image.file(
                          selectedProfileImage!,
                          fit: BoxFit.cover,
                        )
                            : currentProfilePicture != null
                            ? Image.network(
                          currentProfilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderAvatar(),
                        )
                            : _buildPlaceholderAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Tap to change photo',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),

              const SizedBox(height: 30),

              //username Field
              _buildTextField(
                controller: usernameController,
                label: 'Username',
                hint: 'Enter your username',
                icon: Icons.person_outline,
                enabled: !isSaving,
                maxLength: 20,
              ),

              const SizedBox(height: 20),

              //bio Field
              _buildTextField(
                controller: bioController,
                label: 'Bio',
                hint: 'Tell us about yourself',
                icon: Icons.info_outline,
                enabled: !isSaving,
                maxLines: 4,
                maxLength: 150,
              ),

              const SizedBox(height: 30),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your username will be visible to all users. Choose wisely!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //remove Photo Button (if photo exists)
              if (currentProfilePicture != null || selectedProfileImage != null)
                TextButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove profile picture?'),
                        content: const Text(
                            'Your profile will show your initial instead.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setState(() {
                        selectedProfileImage = null;
                        currentProfilePicture = null;
                      });

                      //update Firestore
                      final currentUser = ref.read(authStateProvider).value;
                      if (currentUser != null) {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(currentUser.uid)
                            .update({
                          'profilePicture': FieldValue.delete(),
                        });
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile picture removed'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove profile picture'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 60,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: maxLines > 1
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}