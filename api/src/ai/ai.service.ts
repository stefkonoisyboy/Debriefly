import {
  Injectable,
  InternalServerErrorException,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import {
  AiExtractRequestDto,
  AiExtractResponseDto,
} from './dto/ai-extract.dto';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private ai: GoogleGenAI | null = null;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');

    if (apiKey) {
      this.ai = new GoogleGenAI({ apiKey });
    } else {
      this.logger.warn(
        'GEMINI_API_KEY is not set — AI features will be unavailable',
      );
    }
  }

  async extractDebriefFields(
    dto: AiExtractRequestDto,
  ): Promise<AiExtractResponseDto> {
    if (!this.ai) {
      throw new ServiceUnavailableException('AI provider not configured');
    }

    const prompt = this.buildPrompt(dto.notes);

    try {
      const response = await this.ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
        config: {
          temperature: 0.2,
          responseMimeType: 'application/json',
        },
      });

      const text = response?.text ?? '';
      const result = JSON.parse(text) as AiExtractResponseDto;

      if (!result || typeof result !== 'object') {
        throw new InternalServerErrorException('Invalid AI response structure');
      }

      return result;
    } catch (err) {
      if (
        err instanceof InternalServerErrorException ||
        err instanceof ServiceUnavailableException
      ) {
        throw err;
      }
      this.logger.error('Failed to extract debrief fields via AI', err);

      throw new InternalServerErrorException(
        'Failed to extract debrief fields from notes',
      );
    }
  }

  private buildPrompt(notes: string): string {
    const today = new Date().toISOString().split('T')[0];

    return [
      'You are an expert meeting assistant. Extract structured debrief information from the raw meeting notes provided.',
      'Return STRICT JSON only — no markdown, no code fences, no explanations.',
      `Today's date is ${today}. Use it to infer relative dates like "next Friday" or "yesterday".`,
      '',
      'The JSON MUST match exactly this TypeScript shape (all fields are optional — only include what you can confidently extract):',
      '{',
      '  "clientName": string,          // name of the client / company the meeting was with',
      '  "meetingDate": string,          // ISO date yyyy-MM-dd',
      '  "participants": string,         // comma-separated list of participants with roles, e.g. "Alice (ACME), Bob (Internal)"',
      '  "summary": string,              // bullet-point summary of key discussion topics, each on a new line starting with •',
      '  "decisionsMade": string,        // bullet-point list of decisions, each on a new line starting with •',
      '  "actionItems": [               // list of concrete next steps',
      '    {',
      '      "description": string,     // what needs to be done',
      '      "owner": string,           // person responsible',
      '      "dueDate": string          // ISO date yyyy-MM-dd',
      '    }',
      '  ],',
      '  "risksConcerns": string        // any risks or concerns mentioned',
      '}',
      '',
      'Rules:',
      '- Omit any field you cannot confidently extract from the notes.',
      '- Do NOT fabricate information not present in the notes.',
      '- For bullet-point fields (summary, decisionsMade), prefix each point with "• ".',
      '- Return ONLY the JSON object.',
      '',
      'Meeting notes:',
      notes,
    ].join('\n');
  }
}
