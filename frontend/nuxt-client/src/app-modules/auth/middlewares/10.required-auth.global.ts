import { AuthService } from '~/app-modules/auth/services/auth.service';

const skipFromPaths = [
  '/sent-confirmation-email',
  '/sent-reset-password-email',
  '/confirmation',
  '/registration',
  '/reset-password',
  '/new-password',
];

export default defineNuxtRouteMiddleware((to, from) => {
  const {
    meta: { requiresAuth = true },
    name,
  } = to;

  const authService = useIOC(AuthService);
  const userLoggedIn = authService.isLoggedIn;

  // Условия прервать навигацию и изменить роут назначения
  if (name === 'auth' && userLoggedIn) {
    return from.path === '/auth/' ? '/' : abortNavigation();
  }

  // Условия продолжения навигации
  if (name === 'auth' && !userLoggedIn) {
    return;
  } else if (!requiresAuth || userLoggedIn) {
    return;
  }

  // роут защищен и нет авторизации
  return skipFromPaths.includes(from.path) ? '/auth' : `/auth/?from=${from.path}`;
});

declare module '#app' {
  interface PageMeta {
    /**
     * Установлена по умолчанию как true
     */
    requiresAuth?: boolean;
  }
}

declare module 'vue-router' {
  interface RouteMeta {
    /**
     * Установлена по умолчанию как true
     */
    requiresAuth?: boolean;
  }
}
