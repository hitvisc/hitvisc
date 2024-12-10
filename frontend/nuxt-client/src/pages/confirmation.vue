<template>
  <div class="container container-tight py-4">
    <div class="text-center">
      <div class="mb-3">
        <router-link to="/">
          <x-icon
            icon="icon-boinc"
            :size="30"
          />

          HiTViSc
        </router-link>
      </div>

      <div
        v-if="!token"
        class="text-muted mb-3"
      >
        Token not set
      </div>

      <div
        v-if="error"
        class="text-muted mb-3"
      >
        {{ error }}
      </div>

      <div
        v-if="isLoading"
        class="progress progress-sm"
      >
        <div class="progress-bar progress-bar-indeterminate"></div>
      </div>

      <template v-if="confirmed">
        <div class="my-5">
          <h2 class="h1">{{ $t('confirmationEmail.title') }}</h2>

          <p class="fs-h3 text-muted">
            {{ $t('confirmationEmail.text') }}

            <router-link
              to="/login"
              tabindex="-1"
            >
              {{ $t('confirmationEmail.login') }}
            </router-link>
          </p>
        </div>
      </template>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { UsersClient } from '~/app-modules/users/clients/users.client.js';

definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

const isLoading = ref(false);
const confirmed = ref(false);
const error = ref('');
const token = useRoute().query.token as string | undefined;

const usersClient = useIOC(UsersClient);

if (token) {
  await confirmUser(token);
}

async function confirmUser(token: string) {
  try {
    isLoading.value = true;
    await usersClient.confirmUser(token);
    confirmed.value = true;
  } catch (e: unknown) {
    error.value = e?.response?.data?.message?.[0] ?? e?.message;
  } finally {
    isLoading.value = false;
  }
}
</script>
