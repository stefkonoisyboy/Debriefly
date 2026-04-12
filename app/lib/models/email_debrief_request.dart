class EmailDebriefRequest {
  final List<String> recipients;
  final String subject;

  const EmailDebriefRequest({required this.recipients, required this.subject});

  Map<String, dynamic> toJson() {
    return {'recipients': recipients, 'subject': subject};
  }
}
