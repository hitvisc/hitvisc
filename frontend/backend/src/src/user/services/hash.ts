import { createHash } from 'crypto';

export const hash = (str: string) =>
  createHash('md5').update(str).digest('hex');

export const verify = (strHash: string, str: string) => hash(str) === strHash;
