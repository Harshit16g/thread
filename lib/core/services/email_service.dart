abstract class EmailService {
  Future<void> sendTransactionalEmail({
    required String to,
    required String subject,
    required String html,
  });
  
  Future<void> sendBulkEmail({
    required List<String> recipients,
    required String campaignId,
    required Map<String, dynamic> templateData,
  });
}
