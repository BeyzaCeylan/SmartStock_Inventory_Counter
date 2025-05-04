import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/object_detection_service.dart';
import 'stock_page.dart';
import 'profile_page.dart';
import 'summary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ObjectDetectionService _detectionService = ObjectDetectionService();
  bool _isLoading = false;
  Map<String, dynamic>? _results;
  Map<String, int> _totalCounts = {};
  int _selectedIndex = 0;
  String? userName;
  bool _hasStartedCounting = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['showSnackBar'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current Stocks Updated Successfully!')),
        );
      });
    }
    _resetFlow();
  }

  void _resetFlow() {
    _image = null;
    _results = null;
    _totalCounts = {};
    _hasStartedCounting = false;
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = doc['name'] ?? user.displayName ?? 'Anonim';
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _results = null;
        _hasStartedCounting = true;
      });

      try {
        final results = await _detectionService.detectObjects(_image!);
        if (!mounted) return;
        setState(() {
          _results = results;
          _isLoading = false;

          final objectCounts = results['object_counts'] as Map<String, dynamic>;
          objectCounts.forEach((key, value) {
            _totalCounts[key] = (_totalCounts[key] ?? 0) + (value as int);
          });
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetAndPickImage() {
    setState(() {
      _image = null;
      _results = null;
    });
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Detecting products...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    if (userName == null || userName == 'Anonim') {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_hasStartedCounting) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $userName! 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Welcome to SmartStock!',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Your smart inventory counting assistant is here. Are you ready for fast, accurate and easy inventory tracking?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!_hasStartedCounting) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/grocery_story_photo.png',
                height: 430,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Start with Camera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Start with Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_image != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    if (_results != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detected Products:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._buildResultsList(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () => _resetAndPickImage(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shadowColor: Colors.greenAccent,
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/summary',
                                        arguments: {
                                          'totalCounts': _totalCounts,
                                          'userName': userName ?? 'Anonim',
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shadowColor: Colors.orangeAccent,
                                    ),
                                    child: const Text(
                                      'Done',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildResultsList() {
    if (_results == null || !_results!.containsKey('object_counts')) return [];
    final objectCounts = _results!['object_counts'] as Map<String, dynamic>;
    return objectCounts.entries.map((entry) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(entry.key),
          trailing: Text('${entry.value} piece'),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildMainContent(),
      const StockPage(),
      ProfileEditPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartStock',
          style: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: Colors.green,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.inventory, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
