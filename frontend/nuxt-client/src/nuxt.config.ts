import '@abraham/reflection';
import swc from 'unplugin-swc';
import { Nitro } from 'nitropack';
import { getDirectories } from './app-modules/core/helpers/fs/getDirectories';

const appModulesFolders = getDirectories('./app-modules');

const modulesFoldersToComponentsPrefixes = (folderName: string) => {
  const customComponentPrefix = [
    { name: 'core', prefix: '' },
    { name: 'ux-system', prefix: 'x' },
  ].find((v) => v.name === folderName);

  if (!customComponentPrefix) {
    return folderName;
  }

  return customComponentPrefix.prefix;
};

export default defineNuxtConfig({
  devtools: { enabled: true },

  routeRules: {
    '/**': { ssr: false },
  },

  css: ['~/node_modules/@tabler/core/dist/css/tabler.min.css', '@/assets/styles/globals.scss'],

  app: {
    rootId: 'nuxt-root',
    head: {
      titleTemplate: '%s - HiTViSc',
      title: 'HiTViSc',
      link: [{ rel: 'icon', sizes: '32x32', href: '/favicon.ico' }],
      bodyAttrs: {
        class: 'hidden',
      },
    },
    layoutTransition: {
      name: 'page-blur',
      mode: 'out-in',
    },
  },

  build: {
    transpile: ['vue-toastification'],
  },

  components: {
    dirs: [
      ...appModulesFolders.map((e) => ({
        path: `~/app-modules/${e}/components`,
        prefix: modulesFoldersToComponentsPrefixes(e),
        pathPrefix: false,
      })),
      '~/components',
    ],
  },

  imports: {
    dirs: ['app-modules/*/composables', 'app-modules/*/utils'],
  },

  dir: {
    middleware: 'app-modules/*/middlewares',
    plugins: 'app-modules/*/plugins',
  },

  hooks: {
    'nitro:build:before': (nitro: Nitro) => {
      nitro.options.moduleSideEffects.push('@abraham/reflection');
    },
    close: () => {
      // @see https://github.com/nuxt/cli/issues/169#issuecomment-1729300497
      // Workaround for https://github.com/nuxt/cli/issues/169
      process.exit(0);
    },
  },

  sourcemap: {
    server: false,
    client: false,
  },

  modules: ['@nuxtjs/i18n', '@pinia/nuxt', 'dayjs-nuxt', '@vueuse/nuxt'],

  i18n: {
    vueI18n: './i18n.config.ts',
  },

  vue: {
    propsDestructure: true,
  },

  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: '@use "@/assets/styles/_common.scss" as *;',
        },
      },
    },
    plugins: [
      swc.vite(), // Плагин для восстановления поддержки декораторов в Vite
    ],
  },

  typescript: {
    tsConfig: {
      compilerOptions: {
        verbatimModuleSyntax: false,
      },
    },
  },

  runtimeConfig: {
    public: {
      // Указанные ниже ключи подменяются в рантайме
      // требуется добавить префикс NUXT_PUBLIC_ для env переменной
      // переменная testVar в env должна быть NUXT_PUBLIC_TEST_VAR
      apiBoincaasBaseUrl: '',
    },
  },

  dayjs: {
    locales: ['en', 'ru'],
    plugins: ['relativeTime', 'utc', 'isToday', 'isYesterday', 'isBetween'],
    defaultLocale: 'en',
  },

  compatibilityDate: '2024-07-30',
});
