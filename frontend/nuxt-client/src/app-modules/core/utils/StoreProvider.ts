import { StoreDefinition } from 'pinia';

export function StoreProvider<T extends StoreDefinition>(useStore: T) {
  return class {
    getStore = () => useStore();
  };
}
