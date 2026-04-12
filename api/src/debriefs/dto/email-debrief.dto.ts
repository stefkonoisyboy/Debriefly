import {
  ArrayMinSize,
  IsArray,
  IsEmail,
  IsNotEmpty,
  IsString,
} from 'class-validator';

export class EmailDebriefDto {
  @IsArray()
  @ArrayMinSize(1)
  @IsEmail({}, { each: true })
  recipients!: string[];

  @IsString()
  @IsNotEmpty()
  subject!: string;
}
