import { singleton } from 'tsyringe';
import { AuthorizedClient } from '~/app-modules/core/clients/authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import { RegisterUserDto, UserDtoSchema } from '~/app-modules/users/clients/dto/user.dto';

@singleton()
export class UsersClient extends AuthorizedClient {
  constructor(http: HttpConnection, authService: AuthService) {
    super(http, authService);
  }

  /**
   *  Получение информации о текущем юзере
   */
  async getMe() {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/users/current',
      },
      UserDtoSchema,
    );
  }

  async registerUser(data: RegisterUserDto): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/users/register',
      data,
    });
  }

  async resetUserPassword(token: string, password: string): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/users/new-password',
      data: {
        token,
        password,
      },
    });
  }

  async confirmUser(token: string): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/users/confirm',
      data: {
        token,
      },
    });
  }

  async resendConfirmationLink(): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/users/resend-confirmation-link',
    });
  }
}
