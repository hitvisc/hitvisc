import { type AxiosRequestConfig } from 'axios';
import axios from 'axios';
import { z } from 'zod';
import { NotAuthorizedClient } from './not-authorized-client';
import { HttpConnection } from './http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import { NotLoggedIn } from '~/app-modules/core/errors/not-logged-in';

export class AuthorizedClient extends NotAuthorizedClient {
  constructor(
    httpConnection: HttpConnection,
    private authService: AuthService,
  ) {
    super(httpConnection);
  }

  protected override async executeRequest<T>(
    options: AxiosRequestConfig,
    deserializer?: z.Schema<T>,
  ): Promise<T> {
    if (!this.authService.isLoggedIn) new NotLoggedIn();

    const authToken = this.authService.Bearer;
    try {
      return await super.executeRequest(
        { ...options, headers: { Authorization: `${authToken}` } },
        deserializer,
      );
    } catch (error) {
      if (this.isUnAuthorizedException(error)) {
        this.authService.logout();
        await navigateTo('/auth/');
        throw error;
      } else {
        throw error;
      }
    }
  }

  protected async executeNotAuthorizedRequest<T>(
    options: AxiosRequestConfig,
    deserializer: z.Schema<T>,
  ): Promise<T> {
    return await super.executeRequest(options, deserializer);
  }

  private isUnAuthorizedException(e: unknown) {
    // eslint-disable-next-line
    return axios.isAxiosError(e) && e.response?.status == 401;
  }

  protected async uploadSingleFile(url: string, file: File): Promise<string> {
    const formData = new FormData();
    formData.append('file', file);

    return await this.executeRequest({
      method: 'POST',
      data: formData,
      url,
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  }
}
