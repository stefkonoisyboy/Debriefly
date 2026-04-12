import { Debrief } from '../entities/debrief.entity';
import {
  ActionItemResponseDto,
  DebriefResponseDto,
} from '../dto/debrief-response.dto';

export function toDebriefResponseDto(entity: Debrief): DebriefResponseDto {
  const actionItems: ActionItemResponseDto[] = (entity.actionItems ?? []).map(
    (item) => ({
      description: item.description,
      owner: item.owner,
      dueDate: item.dueDate,
    }),
  );

  return {
    id: entity.id,
    clientName: entity.clientName,
    meetingDate: entity.meetingDate,
    participants: entity.participants ?? null,
    summary: entity.summary ?? null,
    decisionsMade: entity.decisionsMade ?? null,
    actionItems,
    risksConcerns: entity.risksConcerns ?? null,
    status: entity.status,
    createdBy: entity.createdBy,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  };
}
