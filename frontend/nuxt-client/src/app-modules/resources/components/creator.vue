<template>
  <x-modal
    v-model="isVisible"
    :title="$t('resources.creator.title')"
    width="600px"
    :has-footer="false"
    @close="reset()"
  >
    <div class="resource-creator__content placeholder-glow">
      <div>{{ $t('resources.creator.description') }}:</div>

      <div>
        1. {{ $t('resources.creator.1') }}
        <a
          class="link"
          href="https://boinc.berkeley.edu/download.php"
          target="_blank"
          >{{ $t('resources.creator.boincClient') }}</a
        >
      </div>

      <div>2. {{ $t('resources.creator.2') }}</div>

      <div>
        3. {{ $t('resources.creator.3') }}

        <div v-if="isLoading" class="placeholder" style="width: 30ch" />
        <x-copy-text v-else :source="newHostParams.projectUrl"></x-copy-text>

        {{ $t('resources.creator.4') }}
      </div>

      <div>4. {{ $t('resources.creator.5') }}</div>

      <div
        v-if="usersStore.currentUser"
        class="resource-creator__user-info"
      >
        <div>
          {{ $t('resources.creator.email') }}

          <div v-if="isLoading" class="placeholder" style="width: 20ch" />
          <x-copy-text v-else :source="newHostParams.email"></x-copy-text>
        </div>

        <div>
          {{ $t('resources.creator.password') }}

          <div v-if="isLoading" class="placeholder" style="width: 20ch" />
          <x-copy-text v-else :source="newHostParams.password"></x-copy-text>
        </div>
      </div>

      <div>5. {{ $t('resources.creator.6') }}</div>

      <div>6. {{ $t('resources.creator.7') }}</div>

      <div class="d-flex justify-content-center pt-3 pb-0">
        <button
          type="button"
          class="btn btn-primary"
          @click="reset()"
        >
          {{ $t('resources.creator.8') }}
        </button>
      </div>
    </div>
  </x-modal>
</template>

<script lang="ts" setup>
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { HostClient } from '~/app-modules/resources/clients/host.client';

const usersStore = useIOC(UsersStoreProvider).getStore();
const hostClient = useIOC(HostClient);

const newHostParams = reactive({
  email: '',
  password: '',
  projectUrl: '',
});
const isVisible = ref(false);
const isLoading = ref(false);

async function open() {
  isVisible.value = true;
  isLoading.value = true;
  try {
    const params = await hostClient.getNewHostParams();
    Object.assign(newHostParams, params);
  } catch(e) {
    useToast().error('Результат не доступен для скачивания');
  }
  isLoading.value = false;
}

function reset() {
  newHostParams.email = '';
  newHostParams.password = '';
  newHostParams.projectUrl = '';
  isVisible.value = false;
}

defineExpose({
  open,
});
</script>

<style lang="scss" scoped>
.resource-creator {
  &__content div {
    padding-bottom: 6px;
  }

  &__user-info {
    border-left: 0.25rem solid var(--tblr-info);
    margin: 12px 24px;
    padding: 6px 24px;
  }
}
</style>
