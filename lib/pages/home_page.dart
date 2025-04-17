import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../services/object_detection_service.dart';
import 'stock_page.dart';
import 'profile_page.dart';

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
  int _selectedIndex = 0;

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _results = null;
      });

      try {
        final results = await _detectionService.detectObjects(_image!);
        if (!mounted) return;

        setState(() {
          _results = results;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDetectionContent();
      case 1:
        return const StockPage();
      case 2:
        return const ProfilePage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetectionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Nesneler tespit ediliyor...'),
                          ],
                        ),
                      ),
                    if (_results != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tespit Edilen Nesneler:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._buildResultsList(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ),
            ],
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
          title: Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${entry.value}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartStock',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 46, 153, 49),
      ),
      body: _buildMainContent(),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 46, 153, 49),
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
