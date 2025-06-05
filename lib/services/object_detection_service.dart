import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ObjectDetectionService {
  Future<String?> _findAvailableBaseUrl() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    if (wifiIP == null) return null;

    final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    print('Scanning subnet: $subnet.x');

    for (int i = 1; i < 255; i++) {
      final url = 'http://$subnet.$i:5001';
      try {
        final response = await http
            .get(Uri.parse('$url/'))
            .timeout(const Duration(milliseconds: 500));
        if (response.statusCode == 200 || response.statusCode == 404) {
          print('Server found at: $url');
          return url;
        }
      } catch (_) {
        // Bağlantı yoksa atla
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> detectObjects(File imageFile) async {
    final baseUrl = await _findAvailableBaseUrl();

    if (baseUrl == null) {
      throw Exception('Hiçbir sunucuya bağlanılamadı.');
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect'));
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseData);

        // Register to Firestore
        await FirebaseFirestore.instance.collection('detections').add({
          'timestamp': Timestamp.now(),
          'object_counts': result['object_counts'],
        });

        return result;
      } else {
        throw Exception('Nesne tespiti başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print('User name: ${doc['name'] ?? user.displayName ?? 'Anonim'}');
    }
  }
}
