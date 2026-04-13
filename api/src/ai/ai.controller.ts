import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { AiService } from './ai.service';
import {
  AiExtractRequestDto,
  AiExtractResponseDto,
} from './dto/ai-extract.dto';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('extract-debrief')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
  async extractDebrief(
    @Body() dto: AiExtractRequestDto,
  ): Promise<AiExtractResponseDto> {
    return this.aiService.extractDebriefFields(dto);
  }
}
