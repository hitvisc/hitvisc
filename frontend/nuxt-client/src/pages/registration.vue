<template>
  <div class="container container-tight py-4">
    <div class="card card-md">
      <div class="card-body">
        <h2 class="h2 text-center mb-4">{{ $t('registration.title') }}</h2>

        <language-switcher class="auth-change-lang-btn" />

        <form
          autocomplete="off"
          novalidate
          @submit.prevent="onSubmit"
        >
          <div class="mb-3">
            <label class="form-label required">
              {{ $t('registration.email') }}
            </label>

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

          <div class="mb-3">
            <label class="form-label required">
              {{ $t('registration.username') }}
            </label>

            <input
              v-model="name"
              class="form-control"
              :class="{
                'is-invalid': errors.name,
              }"
              :placeholder="$t('registration.usernamePlaceholder')"
              autocomplete="off"
            />

            <x-error-message
              v-if="errors.name"
              :message="errors.name"
              class="invalid-feedback"
            />
          </div>

          <div class="mb-3">
            <label class="form-label required">
              {{ $t('registration.password') }}
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
                  :placeholder="$t('registration.passwordPlaceholder')"
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
              {{ $t('registration.confirmPassword') }}
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
                  :placeholder="$t('registration.confirmPasswordPlaceholder')"
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

          <label class="form-check pt-3">
            <input
              v-model="checkPersonalData"
              class="form-check-input"
              type="checkbox"
              :class="{
                'is-invalid': errors.checkPersonalData,
              }"
            />

            <span class="form-check-label required">
              {{ $t('registration.checkPersonalData') }}
            </span>

            <x-error-message
              v-if="errors.checkPersonalData"
              :message="errors.checkPersonalData"
              class="invalid-feedback"
            />
          </label>

          <div class="form-footer">
            <button
              type="submit"
              class="btn btn-primary w-100"
            >
              {{ $t('registration.submitBtn') }}
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
import { UserService } from '~/app-modules/users/services/users.service';

useHead({
  title: 'Sign up',
});

definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

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
        .regex(passwordRegExp, t('registration.invalidPasswordPattern')),
      confirmPassword: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .regex(passwordRegExp, t('registration.invalidPasswordPattern')),
    })
    .refine((data) => data.password === data.confirmPassword, {
      message: t('registration.invalidConfirmPasswords'),
      path: ['confirmPassword'],
    }),
);

const userSchema = computed(() =>
  z.object({
    email: z
      .string({ required_error: t('validation.required') })
      .min(1, { message: t('validation.required') })
      .email(t('validation.invalidEmail')),
    name: z
      .string({ required_error: t('validation.required') })
      .min(2, { message: t('validation.minLength', { minLength: 2 }) })
      .max(255, { message: t('validation.maxLength', { maxLength: 255 }) }),
    checkPersonalData: z
      .boolean({ required_error: t('registration.invalidCheckPersonalData') })
      .refine((data) => data, t('registration.invalidCheckPersonalData')),
  }),
);

const validationSchema = computed(() =>
  toTypedSchema(z.intersection(userSchema.value, passwordSchema.value)),
);

const { handleSubmit, errors } = useForm({
  validationSchema,
});

const { value: email } = useField('email');
const { value: name } = useField('name');
const { value: password } = useField('password');
const { value: confirmPassword } = useField('confirmPassword');
const { value: checkPersonalData } = useField('checkPersonalData');

const usersService = useIOC(UserService);

const onSubmit = handleSubmit(async (data) => {
  try {
    await usersService.registerUser(data);
    useRouter().push(`/sent-confirmation-email?email=${data.email}`);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().error('Ошибка при регистрации');
    } else {
      throw error;
    }
  }
});
</script>
