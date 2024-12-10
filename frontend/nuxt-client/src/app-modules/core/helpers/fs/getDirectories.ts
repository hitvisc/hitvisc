import { readdirSync } from 'fs';

export function getDirectories(dir: string): string[] {
  return readdirSync(dir, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory())
    .map((dirent) => dirent.name);
}
