import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/services/email_service.dart';

class EmailServiceImpl implements EmailService {
  final Dio _dio = Dio();
  
  @override
  Future<void> sendTransactionalEmail({
    required String to,
    required String subject,
    required String html,
  }) async {
    final apiKey = dotenv.env['RESEND_API_KEY'];
    if (apiKey == null) throw 'RESEND_API_KEY not set';
    
    try {
      await _dio.post(
        'https://api.resend.com/emails',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'from': 'noreply@yourdomain.com',
          'to': [to],
          'subject': subject,
          'html': html,
        },
      );
    } catch (e) {
      throw Exception('Failed to send transactional email: $e');
    }
  }
  
  @override
  Future<void> sendBulkEmail({
    required List<String> recipients,
    required String campaignId,
    required Map<String, dynamic> templateData,
  }) async {
    final apiKey = dotenv.env['BREVO_API_KEY'];
    if (apiKey == null) throw 'BREVO_API_KEY not set';
    
    try {
      await _dio.post(
        'https://api.brevo.com/v3/smtp/email',
        options: Options(
          headers: {
            'api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'to': recipients.map((email) => {'email': email}).toList(),
          'templateId': int.parse(campaignId),
          'params': templateData,
        },
      );
    } catch (e) {
      throw Exception('Failed to send bulk email: $e');
    }
  }
}
