import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { ActionItem } from './action-item.embedded';

@Entity('debriefs')
@Index(['createdBy'])
@Index(['meetingDate'])
@Index(['clientName'])
export class Debrief {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ length: 255 })
  clientName!: string;

  @Column({ type: 'date' })
  meetingDate!: string;

  @Column({ type: 'text', nullable: true })
  participants?: string | null;

  @Column({ type: 'text', nullable: true })
  summary?: string | null;

  @Column({ type: 'text', nullable: true })
  decisionsMade?: string | null;

  @Column({ type: 'jsonb', default: [] })
  actionItems!: ActionItem[];

  @Column({ type: 'text', nullable: true })
  risksConcerns?: string | null;

  @Column({ length: 10, default: 'draft' })
  status!: string;

  @Column({ length: 255 })
  createdBy!: string;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
