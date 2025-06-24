import 'package:flutter/material.dart';
import 'package:lango/services/appwrite_service.dart';
import 'package:lango/core/themes/app_colors.dart';
import 'package:lango/core/themes/typography.dart';
import 'package:appwrite/models.dart' as models;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final models.User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  String? _error;
  String? _success;

  File? _pickedImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    // Load profile image URL from user prefs if available
    final prefs = widget.user.prefs.data;
    if (prefs != null && prefs['photoUrl'] != null && prefs['photoUrl'].toString().isNotEmpty) {
      _profileImageUrl = prefs['photoUrl'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      // Upload profile image if picked
      String? uploadedUrl;
      if (_pickedImage != null) {
        uploadedUrl = await AppwriteService.uploadProfileImage(_pickedImage!, widget.user.$id);
        // Save to user prefs
        await AppwriteService.updateUserPrefs({'photoUrl': uploadedUrl});
        setState(() {
          _profileImageUrl = uploadedUrl;
        });
      }
      // Update name
      if (_nameController.text.trim() != widget.user.name) {
        await AppwriteService.updateName(_nameController.text.trim());
      }
      // Update email
      if (_emailController.text.trim() != widget.user.email) {
        await AppwriteService.updateEmail(_emailController.text.trim(), _passwordController.text);
      }
      // Update password
      if (_passwordController.text.isNotEmpty) {
        await AppwriteService.updatePassword(_passwordController.text);
      }
      setState(() {
        _success = 'Profile updated!';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.grey100,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : null),
                  child: (_pickedImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                      ? const Icon(Icons.account_circle, size: 80, color: Colors.black)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password (leave blank to keep current)'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_success != null)
              Text(_success!, style: const TextStyle(color: Colors.green)),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
