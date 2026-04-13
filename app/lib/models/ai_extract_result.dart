import 'action_item.dart';

class AiExtractResult {
  final String? clientName;
  final String? meetingDate;
  final String? participants;
  final String? summary;
  final String? decisionsMade;
  final List<ActionItem>? actionItems;
  final String? risksConcerns;

  const AiExtractResult({
    this.clientName,
    this.meetingDate,
    this.participants,
    this.summary,
    this.decisionsMade,
    this.actionItems,
    this.risksConcerns,
  });

  factory AiExtractResult.fromJson(Map<String, dynamic> json) {
    return AiExtractResult(
      clientName: json['clientName'] as String?,
      meetingDate: json['meetingDate'] as String?,
      participants: json['participants'] as String?,
      summary: json['summary'] as String?,
      decisionsMade: json['decisionsMade'] as String?,
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      risksConcerns: json['risksConcerns'] as String?,
    );
  }
}
