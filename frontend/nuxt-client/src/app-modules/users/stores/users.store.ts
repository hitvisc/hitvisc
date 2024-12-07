import axios from 'axios';
import { Mutex } from 'async-mutex';
import { UserDto } from '~/app-modules/users/clients/dto/user.dto';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import { UsersClient } from '~/app-modules/users/clients/users.client';
import { UserState } from '~/app-modules/users/enums/UserState';

const useUsersStore = defineStore('UsersStore', () => {
  const authService = useIOC(AuthService);
  const userClient = useIOC(UsersClient);

  const _mutex = new Mutex();
  const currentUser = ref<UserDto | undefined>();

  watch(
    () => authService.isLoggedIn,
    async () => {
      // авторизация потеряна
      if (!authService.isLoggedIn) {
        currentUser.value = undefined;
      } else if (authService.isLoggedIn && !currentUser.value) {
        // авторизация получена
        await loadUser();
      }
    },
  );

  const userName = computed(() => currentUser.value?.name ?? '');

  const userEmail = computed(() => currentUser.value?.email ?? '');

  const userEmailConfirmed = computed(() => currentUser.value?.state !== UserState.New);

  async function loadUser() {
    if (!authService.isLoggedIn) return;

    try {
      await _mutex.runExclusive(async () => {
        currentUser.value = await userClient.getMe();
      });
    } catch (error) {
      if (axios.isAxiosError(error)) {
        authService.logout();
      } else {
        throw error;
      }
    }
  }

  async function initStore() {
    // client side init
    if (currentUser.value) {
      return;
    }

    // server side init
    await loadUser();
  }

  return {
    currentUser,
    userName,
    userEmail,
    userEmailConfirmed,
    initStore,
  };
});

@injectable()
export class UsersStoreProvider {
  getStore = () => useUsersStore();
}
