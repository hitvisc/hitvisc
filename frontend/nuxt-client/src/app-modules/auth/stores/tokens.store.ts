export interface ITokensPair {
  accessToken: string;
}

const useTokensStore = defineStore('TokensStore', () => {
  const tokens = useCookie<ITokensPair | null>('boincaas-auth', { default: () => null });

  const accessToken = computed(() => {
    return `Bearer ${tokens.value?.accessToken || ''}`;
  });

  function setTokens(accessToken: string) {
    dropTokens();
    tokens.value = {
      accessToken,
    };
  }

  function dropTokens() {
    tokens.value = null;
  }

  return {
    tokens,
    accessToken,
    setTokens,
    dropTokens,
  };
});

@injectable()
export class TokensStoreProvider {
  getStore = () => useTokensStore();
}
