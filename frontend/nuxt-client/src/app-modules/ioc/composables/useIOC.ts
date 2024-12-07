import '@abraham/reflection';
import { type InjectionToken } from 'tsyringe';

export const useIOC = <T>(constructor: InjectionToken<T>): T => {
  return useNuxtApp().$ioc.resolve(constructor);
};
