import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesal/core/config/api_config.dart';

class ApiService {
  static Future<List<Map<String, dynamic>>> fetchChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return [];

      final res = await http.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/parents/mobile/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return [];

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      // Merge fatherOf + motherOf + guardianOf
      final allChildren = [
        ...((data['fatherOf'] as List?) ?? []),
        ...((data['motherOf'] as List?) ?? []),
        ...((data['guardianOf'] as List?) ?? []),
      ].cast<Map<String, dynamic>>();

      // Deduplicate by id
      final seen = <String>{};
      final unique = allChildren.where((c) {
        final id = c['id'] as String? ?? '';
        return seen.add(id);
      }).toList();

      return unique.map((student) => {
        'id':            student['id'] ?? '',
        'name':          student['nameAr'] ?? student['nameEn'] ?? 'الطالب',
        'grade':         (student['grade'] as Map?)?['name'] ?? '',
        'image':         student['photo'] ?? '',
        'color':         0xFF6366F1,
        'className':     (student['class'] as Map?)?['name'] ?? '',
        'attendance':    '',
        'homeworkCount': '0',
        'gpa':           'N/A',
        'statusMessage': student['nameAr'] ?? 'الطالب',
        'arrivalTime':   '',
        'teachers':      [],
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
