import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Debrief } from './entities/debrief.entity';
import { CreateDebriefDto } from './dto/create-debrief.dto';
import { UpdateDebriefDto } from './dto/update-debrief.dto';
import { DebriefResponseDto } from './dto/debrief-response.dto';
import { toDebriefResponseDto } from './mappers/debrief.mapper';

@Injectable()
export class DebriefService {
  constructor(
    @InjectRepository(Debrief)
    private readonly debriefRepository: Repository<Debrief>,
  ) {}

  async findAll(
    userId: string,
    status?: string,
  ): Promise<DebriefResponseDto[]> {
    const debriefs = await this.debriefRepository.find({
      where: { createdBy: userId, ...(status ? { status } : {}) },
      order: { meetingDate: 'DESC' },
    });

    return debriefs.map(toDebriefResponseDto);
  }

  async findOne(id: string): Promise<DebriefResponseDto> {
    const entity = await this.findOneEntity(id);
    return toDebriefResponseDto(entity);
  }

  async create(
    createDebriefDto: CreateDebriefDto,
    userId: string,
  ): Promise<DebriefResponseDto> {
    const debrief = this.debriefRepository.create({
      ...createDebriefDto,
      actionItems: createDebriefDto.actionItems ?? [],
      createdBy: userId,
    });

    const saved = await this.debriefRepository.save(debrief);
    return toDebriefResponseDto(saved);
  }

  async update(
    id: string,
    updateDebriefDto: UpdateDebriefDto,
  ): Promise<DebriefResponseDto> {
    await this.findOneEntity(id);
    await this.debriefRepository.update(id, updateDebriefDto);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.findOneEntity(id);
    await this.debriefRepository.delete(id);
  }

  async formatForEmail(id: string): Promise<string> {
    const debrief = await this.findOneEntity(id);
    const lines: string[] = [];

    lines.push(`Debrief: ${debrief.clientName}`);
    lines.push(`Meeting Date: ${debrief.meetingDate}`);
    lines.push('');

    if (debrief.participants) {
      lines.push('Participants:');
      lines.push(debrief.participants);
      lines.push('');
    }

    if (debrief.summary) {
      lines.push('Summary:');
      lines.push(debrief.summary);
      lines.push('');
    }

    if (debrief.decisionsMade) {
      lines.push('Decisions Made:');
      lines.push(debrief.decisionsMade);
      lines.push('');
    }

    if (debrief.actionItems && debrief.actionItems.length > 0) {
      lines.push('Action Items:');
      for (const item of debrief.actionItems) {
        lines.push(
          `  - ${item.description} (Owner: ${item.owner}, Due: ${item.dueDate})`,
        );
      }
      lines.push('');
    }

    if (debrief.risksConcerns) {
      lines.push('Risks & Concerns:');
      lines.push(debrief.risksConcerns);
      lines.push('');
    }

    return lines.join('\n');
  }

  private async findOneEntity(id: string): Promise<Debrief> {
    const debrief = await this.debriefRepository.findOne({ where: { id } });

    if (!debrief) {
      throw new NotFoundException(`Debrief with id ${id} not found`);
    }

    return debrief;
  }
}
