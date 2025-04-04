import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ObjectDetectionService {
  static const String baseUrl = 'http://192.168.1.5:5001'; // Flask sunucusunun adresi

  Future<Map<String, dynamic>> detectObjects(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Nesne tespiti başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }
} 