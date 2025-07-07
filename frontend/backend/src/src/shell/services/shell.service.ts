import { Injectable } from '@nestjs/common';
import { execFile, ExecFileOptions } from 'node:child_process';
import { promisify } from 'node:util';
import { ConfigService } from '@nestjs/config';

const asyncExecFile = promisify(execFile);

@Injectable()
export class ShellService {
  constructor(private readonly configService: ConfigService) {}

  async runShellCommand(command: string, args: string[]) {
    const options: ExecFileOptions = {};
    if (this.configService.get<string>('SHELL_UID')) {
      options.uid = +this.configService.get<number>('SHELL_UID');
    }
    return await asyncExecFile(command, args, options);
  }
}
