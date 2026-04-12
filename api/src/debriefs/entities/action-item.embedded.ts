import { Column } from 'typeorm';
import { IsDateString, IsNotEmpty, IsString } from 'class-validator';

export class ActionItem {
  @Column()
  @IsNotEmpty()
  @IsString()
  description!: string;

  @Column()
  @IsNotEmpty()
  @IsString()
  owner!: string;

  @Column({ type: 'date' })
  @IsDateString()
  @IsNotEmpty()
  dueDate!: string;
}
