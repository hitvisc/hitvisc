import { z } from 'zod';
import { UserState } from '~/app-modules/users/enums/UserState';

export const UserDtoSchema = z.object({
  id: z.number(),
  name: z.string(),
  login: z.string(),
  email: z.string().email(),
  state: z.nativeEnum(UserState),
});

export const RegisterUserDtoSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  password: z.string(),
});

export type UserDto = z.infer<typeof UserDtoSchema>;

export type RegisterUserDto = z.infer<typeof RegisterUserDtoSchema>;
