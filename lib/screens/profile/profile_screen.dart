import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../offline/offline_sync_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isSavingName = false;

  Future<void> _logout() async {
    await _auth.signOut();
    await OfflineSyncService.instance.clearAllLocalData();
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compressing for better reliability
      );
      if (image == null) return;

      setState(() => _isLoading = true);

      final user = _auth.currentUser;
      if (user == null) return;

      // Ensure storage is initialized and path is correct
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');

      final uploadTask = storageRef.putFile(
        File(image.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for completion properly
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL only after successful upload task completion
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update Auth
      await user.updatePhotoURL(downloadUrl);

      // Update Firestore with image_url
      await FirebaseRef.userProfileDoc.set({
        'image_url': downloadUrl,
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Fluttertoast.showToast(msg: "Profile picture updated");
    } catch (e) {
      debugPrint("Storage Error Detail: $e");
      if (e.toString().contains('object-not-found')) {
        Fluttertoast.showToast(
          msg:
              "Upload failed: Please ensure Firebase Storage is enabled in Console.",
        );
      } else {
        Fluttertoast.showToast(msg: "Error uploading image: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Fluttertoast.showToast(msg: "Name cannot be empty");
      return;
    }

    setState(() => _isSavingName = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);

        await FirebaseRef.userProfileDoc.set({
          'displayName': newName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _isEditingName = false;
          _isSavingName = false;
        });
        Fluttertoast.showToast(msg: "Username updated");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating name: $e");
      setState(() => _isSavingName = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? 'N/A';

    return Scaffold(
      appBar: appBarWidget(
        title: 'My Profile',
        context: context,
        color: ColorConstant.greenColor,
        backPress: () => Navigator.pop(context),
        showSearchBar: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseRef.userProfileDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return loadingWidget(context);
          }

          final data = snapshot.data?.data() ?? {};
          final displayName =
              data['displayName'] ?? user?.displayName ?? email.split('@')[0];
          final mobile = data['mobile'] ?? '';
          final photoUrl =
              data['image_url'] ?? data['photoUrl'] ?? user?.photoURL;

          if (!_isEditingName) {
            _nameController.text = displayName;
          }

          return _isLoading
              ? loadingWidget(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: ColorConstant.greenColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.only(bottom: 40, top: 10),
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      backgroundImage:
                                          photoUrl != null &&
                                              photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : null,
                                      child:
                                          (photoUrl == null || photoUrl.isEmpty)
                                          ? Text(
                                              displayName.isNotEmpty
                                                  ? displayName[0].toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: _pickAndUploadImage,
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 20,
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                          color: ColorConstant.greenColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _isEditingName
                                ? _buildEditTile(
                                    icon: Icons.person_outline,
                                    controller: _nameController,
                                    label: "Full Name",
                                    isSaving: _isSavingName,
                                    onSave: _saveName,
                                    onCancel: () =>
                                        setState(() => _isEditingName = false),
                                  )
                                : _buildProfileTile(
                                    icon: Icons.person_outline,
                                    title: 'Full Name',
                                    subtitle: displayName,
                                    onEdit: () =>
                                        setState(() => _isEditingName = true),
                                  ),
                            const SizedBox(height: 16),
                            _buildProfileTile(
                              icon: Icons.email_outlined,
                              title: 'Email Address',
                              subtitle: email,
                            ),
                            const SizedBox(height: 16),
                            mobile.isNotEmpty
                                ? _buildProfileTile(
                                    icon: Icons.phone_android_outlined,
                                    title: 'Mobile Number',
                                    subtitle: mobile,
                                  )
                                : const SizedBox(),
                            SizedBox(height: mobile.isNotEmpty ? 40 : 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstant.pastelRedColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 4,
                                  shadowColor: ColorConstant.pastelRedColor
                                      .withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConstant.greenColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ColorConstant.greenColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.naturalBlackColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildEditTile({
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required bool isSaving,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConstant.greenColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ColorConstant.greenColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (isSaving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorConstant.greenColor,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: ColorConstant.greenColor),
              onPressed: onSave,
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
