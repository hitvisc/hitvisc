<template>
  <div class="container container-tight py-4">
    <div class="card card-md">
      <div class="card-body">
        <h2 class="h2 text-center mb-4">{{ $t('resetPassword.newPasswordTitle') }}</h2>

        <language-switcher class="auth-change-lang-btn" />

        <form
          v-if="!isReset"
          autocomplete="off"
          novalidate
          @submit.prevent="onSubmit"
        >
          <div class="mb-3">
            <label class="form-label required">
              {{ $t('resetPassword.newPassword') }}
            </label>

            <div class="row">
              <div class="col">
                <input
                  v-model="password"
                  :type="showPassword ? 'text' : 'password'"
                  class="form-control"
                  :class="{
                    'is-invalid': errors.password,
                  }"
                  :placeholder="$t('resetPassword.newPasswordPlaceholder')"
                  autocomplete="off"
                />

                <x-error-message
                  v-if="errors.password"
                  :message="errors.password"
                  class="invalid-feedback"
                />
              </div>

              <div class="col-auto">
                <button
                  class="btn btn-icon"
                  type="button"
                  @click="showPassword = !showPassword"
                >
                  <x-icon
                    :icon="showPassword ? 'icon-eye-off' : 'icon-eye'"
                    :size="20"
                  ></x-icon>
                </button>
              </div>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label required">
              {{ $t('resetPassword.confirmPassword') }}
            </label>

            <div class="row">
              <div class="col">
                <input
                  v-model="confirmPassword"
                  :type="showConfirmPassword ? 'text' : 'password'"
                  class="form-control"
                  :class="{
                    'is-invalid': errors.confirmPassword,
                  }"
                  :placeholder="$t('resetPassword.confirmPasswordPlaceholder')"
                  autocomplete="off"
                />

                <x-error-message
                  v-if="errors.confirmPassword"
                  :message="errors.confirmPassword"
                  class="invalid-feedback"
                />
              </div>

              <div class="col-auto">
                <button
                  class="btn btn-icon"
                  type="button"
                  @click="showConfirmPassword = !showConfirmPassword"
                >
                  <x-icon
                    :icon="showConfirmPassword ? 'icon-eye-off' : 'icon-eye'"
                    :size="20"
                  ></x-icon>
                </button>
              </div>
            </div>
          </div>

          <div class="form-footer">
            <button
              type="submit"
              class="btn btn-primary w-100"
            >
              {{ $t('resetPassword.submitBtn') }}
            </button>
          </div>
        </form>

        <div
          v-else
          class="text-center"
        >
          <div class="d-flex align-center justify-content-center mb-3 fs-2">
            <x-icon
              icon="icon-check"
              :size="20"
              style="margin-right: 8px"
            ></x-icon>
            {{ $t('resetPassword.passwordChanged') }}
          </div>
          <router-link
            to="/auth"
            tabindex="-1"
          >
            <button class="btn btn-primary">
              {{ $t('login.login') }}
            </button>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { z } from 'zod';
import { useField, useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import axios from 'axios';
import { UserService } from '~/app-modules/users/services/users.service';

useHead({
  title: 'Set new password',
});

definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

const token = useRoute().query.token as string | undefined;
if (!token) {
  await useRouter().replace('/auth');
}

const isReset = ref(false);

const showPassword = ref(false);

const showConfirmPassword = ref(false);

const { t } = useI18n();

const passwordRegExp = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*_=+-]).{8,16}$/;

const passwordSchema = computed(() =>
  z
    .object({
      password: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .regex(passwordRegExp, t('resetPassword.invalidPasswordPattern')),
      confirmPassword: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .regex(passwordRegExp, t('resetPassword.invalidPasswordPattern')),
    })
    .refine((data) => data.password === data.confirmPassword, {
      message: t('resetPassword.invalidConfirmPasswords'),
      path: ['confirmPassword'],
    }),
);

const validationSchema = computed(() => toTypedSchema(passwordSchema.value));

const { handleSubmit, errors } = useForm({
  validationSchema,
});

const { value: password } = useField('password');
const { value: confirmPassword } = useField('confirmPassword');

const usersService = useIOC(UserService);

const onSubmit = handleSubmit(async ({ password }) => {
  try {
    await usersService.resetUserPassword(token!, password);
    isReset.value = true;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().error('Ошибка при сбросе пароля');
    } else {
      throw error;
    }
  }
});
</script>
