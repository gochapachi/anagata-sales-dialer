import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead.dart';

class ApiService {
  static const String defaultWebhookBaseUrl = 'https://n8n.anagataitsolutions.in/webhook';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('n8n_base_url') ?? defaultWebhookBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('n8n_base_url', url.trim());
  }

  static Future<String> getRepName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('rep_name') ?? 'Founder / Sales Rep';
  }

  static Future<void> setRepName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rep_name', name.trim());
  }

  /// Fetches daily assigned leads from n8n -> Odoo 18
  static Future<List<Lead>> fetchLeads() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/get-leads');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Lead.fromJson(item)).toList();
        } else if (data is Map && data.containsKey('data')) {
          final List list = data['data'];
          return list.map((item) => Lead.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching leads: $e');
      return [];
    }
  }

  /// Uploads completed call metadata and audio recording file to n8n -> Odoo 18
  static Future<bool> uploadCallLog({
    required int leadId,
    required int durationSeconds,
    required String callOutcome,
    required String notes,
    required String clientPhone,
    File? audioFile,
  }) async {
    final baseUrl = await getBaseUrl();
    final repName = await getRepName();
    final url = Uri.parse('$baseUrl/call-log');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['lead_id'] = leadId.toString();
      request.fields['duration_seconds'] = durationSeconds.toString();
      request.fields['call_outcome'] = callOutcome;
      request.fields['notes'] = notes;
      request.fields['rep_name'] = repName;
      request.fields['client_phone'] = clientPhone;

      if (audioFile != null && await audioFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio_file',
            audioFile.path,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading call log: $e');
      return false;
    }
  }
}
