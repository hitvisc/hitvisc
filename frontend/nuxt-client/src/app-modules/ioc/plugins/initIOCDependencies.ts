import { TokensStoreProvider } from '~/app-modules/auth/stores/tokens.store';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';

// Плагин для инициализации хранилищ данных и IOC зависимостей, вызывается дважды на сервере и клиенте,
// для корректной гидратации на ssr необходимо учитывать передаваемые типы данных и исключать повторную загрузку
//
export default defineNuxtPlugin(async (_nuxtApp) => {
  useIOC(TokensStoreProvider).getStore();

  const usersStore = useIOC(UsersStoreProvider).getStore();
  await usersStore.initStore();
});
