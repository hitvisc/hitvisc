<template>
  <div>
    <div class="page-header d-print-none">
      <div class="container-xl">
        <div class="row g-2 align-items-center">
          <div class="col">
            <div class="page-pretitle">
              {{ $t('section') }}
            </div>

            <h2 class="page-title">
              {{ $t('features.notifications') }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <app-in-work />
  </div>
</template>
