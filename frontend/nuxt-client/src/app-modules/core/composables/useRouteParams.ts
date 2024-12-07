import { z } from 'zod';

export const useRouteParams = <T>(schema: z.Schema<T>) => {
  const { params } = useRoute();
  const result = schema.safeParse(params);
  if (!result.success) {
    throw createError({
      message: 'Некорректные параметры страницы',
    });
  }
  return result.data;
};
