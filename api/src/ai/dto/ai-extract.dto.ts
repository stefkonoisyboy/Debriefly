import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class AiExtractRequestDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(10000)
  notes!: string;
}

export class AiExtractedActionItemDto {
  description!: string;
  owner!: string;
  dueDate!: string;
}

export class AiExtractResponseDto {
  clientName?: string;
  meetingDate?: string;
  participants?: string;
  summary?: string;
  decisionsMade?: string;
  actionItems?: AiExtractedActionItemDto[];
  risksConcerns?: string;
}
