import { Injectable } from '@nestjs/common';
import { exec, ExecOptions } from 'node:child_process';
import { promisify } from 'node:util';
import { ConfigService } from '@nestjs/config';

const asyncExec = promisify(exec);

@Injectable()
export class ShellService {
  constructor(private readonly configService: ConfigService) {}

  async runShellCommand(command: string) {
    const options: ExecOptions = {};
    if (this.configService.get<string>('SHELL_UID')) {
      options.uid = +this.configService.get<number>('SHELL_UID');
    }
    return await asyncExec(command, options);
  }
}
