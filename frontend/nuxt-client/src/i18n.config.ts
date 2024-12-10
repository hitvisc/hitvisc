import en from '~/assets/i18n/en.json';
import ru from '~/assets/i18n/ru.json';

export default defineI18nConfig(() => {
  return {
    legacy: false,
    locale: 'ru',
    messages: {
      en,
      ru,
    },
  };
});
