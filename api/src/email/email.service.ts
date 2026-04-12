import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { Transporter } from 'nodemailer';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly transporter: Transporter;

  constructor(private readonly configService: ConfigService) {
    this.transporter = nodemailer.createTransport({
      host: this.configService.get<string>('SMTP_HOST', 'localhost'),
      port: this.configService.get<number>('SMTP_PORT', 1025),
      secure: false,
      auth: this.configService.get<string>('SMTP_USER')
        ? {
            user: this.configService.get<string>('SMTP_USER'),
            pass: this.configService.get<string>('SMTP_PASS'),
          }
        : undefined,
    });
  }

  async sendDebriefEmail(
    recipients: string[],
    subject: string,
    content: string,
  ): Promise<void> {
    const from = this.configService.get<string>(
      'SMTP_FROM',
      'support@debriefly.com',
    );

    try {
      await this.transporter.sendMail({
        from,
        to: recipients.join(', '),
        subject,
        text: content,
        html: this.toHtml(content),
      });

      this.logger.log(
        `Debrief email sent to [${recipients.join(', ')}] with subject "${subject}"`,
      );
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);

      this.logger.error(
        `Failed to send debrief email to [${recipients.join(', ')}]: ${message}`,
        error instanceof Error ? error.stack : undefined,
      );

      throw new Error(`Email delivery failed: ${message}`);
    }
  }

  private toHtml(text: string): string {
    return `<pre style="font-family: sans-serif; white-space: pre-wrap;">${this.escapeHtml(text)}</pre>`;
  }

  private escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}
