import 'action_item.dart';

class Debrief {
  final String id;
  final String clientName;
  final String meetingDate;
  final String? participants;
  final String? summary;
  final String? decisionsMade;
  final String? risksConcerns;
  final List<ActionItem> actionItems;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  const Debrief({
    required this.id,
    required this.clientName,
    required this.meetingDate,
    this.participants,
    this.summary,
    this.decisionsMade,
    this.risksConcerns,
    required this.actionItems,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Debrief.fromJson(Map<String, dynamic> json) {
    final rawActionItems = json['actionItems'];
    final actionItems = rawActionItems is List
        ? rawActionItems
              .map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
              .toList()
        : <ActionItem>[];

    return Debrief(
      id: json['id'] as String,
      clientName: json['clientName'] as String,
      meetingDate: json['meetingDate'] as String,
      participants: json['participants'] as String?,
      summary: json['summary'] as String?,
      decisionsMade: json['decisionsMade'] as String?,
      risksConcerns: json['risksConcerns'] as String?,
      actionItems: actionItems,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'meetingDate': meetingDate,
      'participants': participants,
      'summary': summary,
      'decisionsMade': decisionsMade,
      'risksConcerns': risksConcerns,
      'actionItems': actionItems.map((e) => e.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Debrief copyWith({
    String? id,
    String? clientName,
    String? meetingDate,
    String? participants,
    String? summary,
    String? decisionsMade,
    String? risksConcerns,
    List<ActionItem>? actionItems,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return Debrief(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      meetingDate: meetingDate ?? this.meetingDate,
      participants: participants ?? this.participants,
      summary: summary ?? this.summary,
      decisionsMade: decisionsMade ?? this.decisionsMade,
      risksConcerns: risksConcerns ?? this.risksConcerns,
      actionItems: actionItems ?? this.actionItems,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Debrief && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Debrief(id: $id, clientName: $clientName, meetingDate: $meetingDate)';
}
