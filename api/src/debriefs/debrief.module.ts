import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Debrief } from './entities/debrief.entity';
import { DebriefService } from './debrief.service';
import { DebriefController } from './debrief.controller';
import { EmailModule } from '../email/email.module';

@Module({
  imports: [TypeOrmModule.forFeature([Debrief]), EmailModule],
  controllers: [DebriefController],
  providers: [DebriefService],
  exports: [DebriefService],
})
export class DebriefModule {}
