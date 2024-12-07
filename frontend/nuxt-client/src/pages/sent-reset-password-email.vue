<template>
  <div class="page page-center">
    <div class="container container-tight py-4">
      <div class="text-center">
        <router-link to="/">
          <x-icon
            icon="icon-boinc"
            :size="30"
          ></x-icon>

          HiTViSc
        </router-link>

        <div class="my-5">
          <h2 class="h1">{{ $t('sentResetPasswordEmail.title') }}</h2>

          <p class="fs-h3 text-muted">
            {{ $t('sentResetPasswordEmail.text', { email }) }}
            <br />
            {{ $t('sentResetPasswordEmail.clickText') }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

const email = useRoute().query.email;
</script>
