import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectDetectionService {
  static const String baseUrl = 'http://10.0.2.2:5001'; // Emülatör için Flask adresi

  Future<Map<String, dynamic>> detectObjects(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseData);

        // ✅ Firestore'a kayıt
        await FirebaseFirestore.instance.collection('detections').add({
          'timestamp': Timestamp.now(),
          'object_counts': result['object_counts'], // {'Cola': 2, 'Pepsi': 1} gibi
        });

        return result;
      } else {
        throw Exception('Nesne tespiti başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }
}
