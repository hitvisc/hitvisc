import { singleton } from 'tsyringe';
import { NotAuthorizedClient } from '~/app-modules/core/clients/not-authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import {
  SuccessLoginDto,
  SuccessLoginDtoSchema,
} from '~/app-modules/auth/clients/dto/success-login.dto';

@singleton()
export class AuthClient extends NotAuthorizedClient {
  constructor(connection: HttpConnection) {
    super(connection);
  }

  /**
   * Авторизация по паре email и пароль
   */
  async authorize(email: string, password: string): Promise<SuccessLoginDto> {
    return await this.executeRequest(
      {
        method: 'post',
        url: '/api/users/login',
        data: {
          email,
          password,
        },
      },
      SuccessLoginDtoSchema,
    );
  }

  /**
   * Запрос на сброс пароля
   */
  async resetPassword(email: string): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/users/reset-password',
      data: {
        email,
      },
    });
  }
}
