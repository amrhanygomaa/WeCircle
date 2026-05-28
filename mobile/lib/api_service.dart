import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://44.201.109.24:5001/api';
  
  // We mock a fixed schoolId or token here for demo purposes since auth is skipped for MVP
  static Future<List<Map<String, dynamic>>> fetchChildren() async {
    try {
      // In a real scenario we use headers with JWT token.
      // Since we just seeded the DB, we fetch students.
      final response = await http.get(Uri.parse('$baseUrl/students?limit=10'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List students = data['data'];
          
          return students.map((student) => {
            'id': student['id'],
            'name': student['nameAr'] ?? student['user']['fullName'],
            'grade': student['grade']?['name'] ?? 'الصف الأول',
            'image': student['photo'] ?? 'https://i.pravatar.cc/150?u=${student['id']}',
            'color': 0xFF6366F1, // Default color for UI
            'attendance': '${student['points'] ?? 95}%', // Using points as a mock stat for now
            'homeworkCount': '0',
            'gpa': 'A',
            'statusMessage': '${student['nameAr'] ?? 'الطالب'} في المدرسة حالياً',
            'arrivalTime': '07:45 ص',
            'teachers': ['مدرس العلوم', 'مدرس العربي'],
          }).toList();
        }
      }
    } catch (e) {
      print("API Error: $e");
    }
    return [];
  }
}
