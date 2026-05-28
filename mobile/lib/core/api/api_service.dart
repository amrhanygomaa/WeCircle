import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wesal/core/config/api_config.dart';

class ApiService {
  static Future<List<Map<String, dynamic>>> fetchChildren() async {
    final String baseUrl = ApiConfig.getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/students?limit=10'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List students = data['data'];
          
          return students.map((student) => {
            'id': student['id'],
            'name': student['nameAr'] ?? student['user']['fullName'],
            'grade': student['grade']?['name'] ?? 'الصف الأول',
            'image': student['photo'] ?? '',
            'color': 0xFF6366F1, 
            'attendance': student['points'] != null ? '${student['points']}%' : 'N/A', 
            'homeworkCount': '0',
            'gpa': 'N/A',
            'statusMessage': '${student['nameAr'] ?? 'الطالب'}',
            'arrivalTime': '',
            'teachers': [],
          }).toList();
        }
      }
    } catch (e) {
      print("API Error: $e");
    }
    return [];
  }
}
