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
        title: const Text('Hesabım',
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
                'Fotoğraf değiştirmek için tıklayın',
                style: TextStyle(
                    color: Colors.green.shade800, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, "Ad", Icons.person,
                  enabled: isEditing),
              _buildTextField(surnameController, "Soyad", Icons.person_outline,
                  enabled: isEditing),
              _buildTextField(emailController, "E-posta", Icons.email,
                  enabled: false),
              _buildTextField(phoneController, "Telefon", Icons.phone,
                  enabled: isEditing),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _changePassword,
                child: const Text(
                  'Şifrenizi değiştirmek için tıklayın',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isEditing ? _updateProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEditing ? const Color(0xFF26A42C) : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kaydet', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() => isEditing = true);
                },
                child: const Text(
                  'Bilgileri Düzenle',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Çıkış Yap',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
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
