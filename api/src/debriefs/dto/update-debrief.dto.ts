import {
  IsArray,
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ActionItemDto } from './action-item.dto';

export class UpdateDebriefDto {
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientName?: string;

  @IsDateString()
  @IsOptional()
  meetingDate?: string;

  @IsString()
  @IsOptional()
  participants?: string;

  @IsString()
  @IsOptional()
  summary?: string;

  @IsString()
  @IsOptional()
  decisionsMade?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ActionItemDto)
  @IsOptional()
  actionItems?: ActionItemDto[];

  @IsString()
  @IsOptional()
  risksConcerns?: string;

  @IsString()
  @IsIn(['draft', 'sent'])
  @IsOptional()
  status?: string;
}
