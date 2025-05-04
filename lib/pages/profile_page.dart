import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String? profileImageUrl;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    surnameController = TextEditingController();
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        nameController.text = doc['name'] ?? '';
        surnameController.text = doc['surname'] ?? '';
        phoneController.text = doc['phone'] ?? '';
        profileImageUrl = doc['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user.uid}.jpg');
      await storageRef.putFile(File(pickedFile.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'photoUrl': downloadUrl,
      });

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!')),
      );
    }
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': nameController.text,
      'surname': surnameController.text,
      'phone': phoneController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );

    setState(() {
      isEditing = false;
    });
  }

  Future<void> _changePassword() async {
    // Firebase password reset link
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent!')),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF26A42C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.green)
                      : null,
                  backgroundColor: Colors.green.shade100,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click to Change Your Picture',
                style: TextStyle(
                    color: Colors.green.shade800, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, "Name", Icons.person,
                  enabled: isEditing),
              _buildTextField(surnameController, "Surname", Icons.person_outline,
                  enabled: isEditing),
              _buildTextField(emailController, "E-Mail", Icons.email,
                  enabled: false),
              _buildTextField(phoneController, "Phone Number", Icons.phone,
                  enabled: isEditing),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _changePassword,
                child: const Text(
                  'Click to Change Your Password',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isEditing ? _updateProfile : null,
                      icon: const Icon(Icons.save, size: 22),
                      label: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEditing ? Color(0xFF26A42C) : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.greenAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => isEditing = true);
                      },
                      icon: const Icon(Icons.edit, size: 22),
                      label: const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF26A42C),
                        elevation: 4,
                        side: const BorderSide(color: Color(0xFF26A42C), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 22),
                label: const Text('Log Out', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
} 