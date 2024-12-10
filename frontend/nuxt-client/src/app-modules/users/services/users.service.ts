import axios from 'axios';
import { UsersClient } from '~/app-modules/users/clients/users.client';
import { RegisterUserDto } from '~/app-modules/users/clients/dto/user.dto';

@singleton()
export class UserService {
  constructor(protected usersClient: UsersClient) {}

  async getMe() {
    try {
      return await this.usersClient.getMe();
    } catch (error) {
      if (!axios.isAxiosError(error)) {
        console.error(error);
        throw error;
      }
    }
  }

  async registerUser(dto: RegisterUserDto) {
    return await this.usersClient.registerUser(dto);
  }

  async resetUserPassword(token: string, password: string) {
    return await this.usersClient.resetUserPassword(token, password);
  }
}
