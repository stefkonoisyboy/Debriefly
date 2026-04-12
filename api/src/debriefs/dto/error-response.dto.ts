import { HttpStatus } from '@nestjs/common';

export class ErrorResponseDto {
  statusCode!: HttpStatus;
  message!: string | string[];
  error?: string;
  timestamp!: string;
  path?: string;
}
