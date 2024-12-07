<template>
  <div class="container container-tight py-4">
    <div class="card card-md">
      <div class="card-body">
        <h2 class="h2 text-center mb-4">{{ $t('resetPassword.title') }}</h2>

        <language-switcher class="auth-change-lang-btn" />

        <form
          autocomplete="off"
          novalidate
          @submit.prevent="onSubmit"
        >
          <div class="mb-3">
            <label class="form-label">{{ $t('resetPassword.email') }}</label>

            <input
              v-model="email"
              type="email"
              class="form-control"
              :class="{
                'is-invalid': errors.email,
              }"
              placeholder="your@email.com"
              autocomplete="off"
            />

            <x-error-message
              v-if="errors.email"
              :message="errors.email"
              class="invalid-feedback"
            />
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
      </div>
    </div>

    <div class="text-center text-muted mt-3">
      {{ $t('login.haveAccount') }}
      <router-link
        to="/auth"
        tabindex="-1"
      >
        {{ $t('login.login') }}
      </router-link>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { z } from 'zod';
import { useField, useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import axios from 'axios';
import { AuthService } from '~/app-modules/auth/services/auth.service';

useHead({
  title: 'Reset password',
});

definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

const { t } = useI18n();

const validationSchema = computed(() =>
  toTypedSchema(
    z.object({
      email: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .email(t('validation.invalidEmail')),
    }),
  ),
);

const { handleSubmit, errors } = useForm({
  validationSchema,
});

const { value: email } = useField('email');

const authService = useIOC(AuthService);
const onSubmit = handleSubmit(async ({ email }) => {
  try {
    await authService.resetPassword(email);
    useRouter().push(`/sent-reset-password-email?email=${email}`);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().error('Ошибка сброса пароля');
    } else {
      throw error;
    }
  }
});
</script>
