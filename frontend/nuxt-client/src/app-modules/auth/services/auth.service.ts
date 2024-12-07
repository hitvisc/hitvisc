import { TokensStoreProvider } from '../stores/tokens.store';
import { AuthClient } from '~/app-modules/auth/clients/auth.client';

@singleton()
export class AuthService {
  constructor(
    protected tokensStore: TokensStoreProvider,
    protected authClient: AuthClient,
  ) {}

  get Bearer(): String {
    return this.tokensStore.getStore().accessToken;
  }

  get isLoggedIn(): boolean {
    return this.tokensStore.getStore().tokens !== null;
  }

  async authorize(email: string, password: string) {
    if (this.isLoggedIn) {
      this.logout();
    }
    const loginResult = await this.authClient.authorize(email, password);
    this.tokensStore.getStore().setTokens(loginResult.jwt);
  }

  async resetPassword(email: string) {
    await this.authClient.resetPassword(email);
  }

  logout() {
    this.tokensStore.getStore().dropTokens();
  }
}
