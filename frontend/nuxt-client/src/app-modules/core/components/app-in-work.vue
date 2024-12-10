<template>
  <div class="container-tight py-4">
    <div class="empty">
      <div class="empty-img">
        <x-icon
          icon="in-work"
          :size="200"
        ></x-icon>
      </div>

      <p class="empty-title">{{ $t('inWork.title') }}</p>

      <p class="empty-subtitle text-secondary">
        {{ $t('inWork.description') }}
      </p>
    </div>
  </div>
</template>
