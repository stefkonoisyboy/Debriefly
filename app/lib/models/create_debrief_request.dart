import 'action_item.dart';

class CreateDebriefRequest {
  final String clientName;
  final String meetingDate;
  final String? participants;
  final String? summary;
  final String? decisionsMade;
  final String? risksConcerns;
  final List<ActionItem>? actionItems;
  final String status;

  const CreateDebriefRequest({
    required this.clientName,
    required this.meetingDate,
    this.participants,
    this.summary,
    this.decisionsMade,
    this.risksConcerns,
    this.actionItems,
    this.status = 'draft',
  });

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'meetingDate': meetingDate,
      if (participants != null) 'participants': participants,
      if (summary != null) 'summary': summary,
      if (decisionsMade != null) 'decisionsMade': decisionsMade,
      if (risksConcerns != null) 'risksConcerns': risksConcerns,
      if (actionItems != null)
        'actionItems': actionItems!.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }
}
