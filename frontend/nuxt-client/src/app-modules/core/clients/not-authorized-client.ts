import { type AxiosRequestConfig } from 'axios';
import { z } from 'zod';
import { HttpConnection } from './http-connection';
import { type HttpResponse } from '~/app-modules/core/types/http-response';

export type Deserializer<T> = (response: HttpResponse) => T;

export class NotAuthorizedClient {
  constructor(protected connection: HttpConnection) {
    ensureInstanceOf(HttpConnection, { connection });
  }

  protected async executeRequest<T>(
    options: AxiosRequestConfig,
    deserializer: z.Schema<T> = z.optional(z.any()),
  ): Promise<T> {
    const _result = await this.connection.executeRequest(options);
    return deserializer.parse(_result);
  }
}
