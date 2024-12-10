import { Dayjs } from 'dayjs';

// declare module '#app' {
//   interface NuxtApp {
//     $formatDate(date: string | number | Date | Dayjs, format: string): string,
//   }
// }
//
// declare module 'vue' {
//   interface ComponentCustomProperties {
//     $formatDate(date: string | number | Date | Dayjs, format: string): string,
//   }
// }
//
export default defineNuxtPlugin((nuxtApp) => {
  const dayjs = useDayjs();

  const formatDate = (date: string | number | Date | Dayjs, format: string) =>
    dayjs(date)
      .locale((nuxtApp.$i18n as any).locale.value)
      .format(format);

  return {
    provide: {
      formatDate,
    },
  };
});
