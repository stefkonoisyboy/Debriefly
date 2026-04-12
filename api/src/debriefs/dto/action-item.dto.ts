import { IsDateString, IsNotEmpty, IsString } from 'class-validator';

export class ActionItemDto {
  @IsString()
  @IsNotEmpty()
  description!: string;

  @IsString()
  @IsNotEmpty()
  owner!: string;

  @IsDateString()
  @IsNotEmpty()
  dueDate!: string;
}
