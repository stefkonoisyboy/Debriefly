import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Put,
  Query,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { DebriefService } from './debrief.service';
import { EmailService } from '../email/email.service';
import { CreateDebriefDto } from './dto/create-debrief.dto';
import { UpdateDebriefDto } from './dto/update-debrief.dto';
import { EmailDebriefDto } from './dto/email-debrief.dto';
import { DebriefResponseDto } from './dto/debrief-response.dto';

// Placeholder user ID used until real authentication is integrated.
const PLACEHOLDER_USER_ID = 'anonymous';

@Controller('debriefs')
@UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
export class DebriefController {
  constructor(
    private readonly debriefService: DebriefService,
    private readonly emailService: EmailService,
  ) {}

  /** POST /debriefs — create a new debrief */
  @Post()
  create(
    @Body() createDebriefDto: CreateDebriefDto,
    @Headers('x-user-id') userId?: string,
  ): Promise<DebriefResponseDto> {
    return this.debriefService.create(
      createDebriefDto,
      userId ?? PLACEHOLDER_USER_ID,
    );
  }

  /** GET /debriefs — list all debriefs for the requesting user */
  @Get()
  findAll(
    @Headers('x-user-id') userId?: string,
    @Query('status') status?: string,
  ): Promise<DebriefResponseDto[]> {
    return this.debriefService.findAll(userId ?? PLACEHOLDER_USER_ID, status);
  }

  /** GET /debriefs/:id — get a single debrief by id */
  @Get(':id')
  findOne(@Param('id') id: string): Promise<DebriefResponseDto> {
    return this.debriefService.findOne(id);
  }

  /** PUT /debriefs/:id — update an existing debrief */
  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() updateDebriefDto: UpdateDebriefDto,
  ): Promise<DebriefResponseDto> {
    return this.debriefService.update(id, updateDebriefDto);
  }

  /** DELETE /debriefs/:id — remove a debrief */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.debriefService.remove(id);
  }

  /** POST /debriefs/:id/email — send a debrief via email */
  @Post(':id/email')
  @HttpCode(HttpStatus.NO_CONTENT)
  async sendEmail(
    @Param('id') id: string,
    @Body() emailDebriefDto: EmailDebriefDto,
  ): Promise<void> {
    const content = await this.debriefService.formatForEmail(id);

    await this.emailService.sendDebriefEmail(
      emailDebriefDto.recipients,
      emailDebriefDto.subject,
      content,
    );
  }
}
