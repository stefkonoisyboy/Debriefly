export class ActionItemResponseDto {
  description!: string;
  owner!: string;
  dueDate!: string;
}

export class DebriefResponseDto {
  id!: string;
  clientName!: string;
  meetingDate!: string;
  participants?: string | null;
  summary?: string | null;
  decisionsMade?: string | null;
  actionItems!: ActionItemResponseDto[];
  risksConcerns?: string | null;
  status!: string;
  createdBy!: string;
  createdAt!: Date;
  updatedAt!: Date;
}
