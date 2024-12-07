<template>
  <div>
    <div class="page-header d-print-none pb-4">
      <div class="container-xl">
        <div class="row g-2 align-items-center">
          <div class="col">
            <div class="page-pretitle">
              {{ $t('section') }}
            </div>

            <h2 class="page-title">
              {{ $t('features.resources') }}:
              {{ $t(`resources.sections.${usageType}`) }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="container-xl">
      <div class="row">
        <div class="col-12">
          <button
            v-if="canAddResource"
            class="btn btn-primary mb-3"
            @click="openCreator()"
          >
            <x-icon
              icon="icon-plus"
              :size="18"
            ></x-icon>

            {{ $t('resources.addBtn') }}
          </button>

          <resources-creator ref="resourcesCreatorRef" />

          <resources-host-editor
            ref="hostEditorRef"
            @updated="onHostUpdated"
          />

          <div>
            <label class="form-check form-switch d-inline-block">
              <input
                v-model="showInactive"
                class="form-check-input"
                type="checkbox"
              />
              <span class="form-check-label">Показывать неактивные</span>
            </label>
          </div>

          <resources-table
            ref="hostsTableRef"
            :usage-type="hostUsageTypeEnumValue"
            :show-inactive="showInactive"
            @edit="showEditDialog"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { z } from 'zod';
import ResourceCreator from '~/app-modules/resources/components/creator.vue';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';
import { HostDto } from '~/app-modules/resources/clients/dto/host.dto';
import HostEditor from '~/app-modules/resources/components/host-editor.vue';
import Table from '~/app-modules/resources/components/table.vue';

const { usageType } = useRouteParams(
  z.object({
    usageType: z.string(),
  }),
);

const showInactive = ref(false);

const hostUsageTypeEnumValue = computed(
  () =>
    ({
      public: HostUsageType.Public,
      private: HostUsageType.Private,
      test: HostUsageType.Test,
    })[usageType] ?? HostUsageType.Public,
);

const canAddResource = computed(() => ['public', 'private'].includes(usageType));

const resourcesCreatorRef = ref<InstanceType<typeof ResourceCreator> | null>(null);

function openCreator() {
  resourcesCreatorRef.value?.open();
}

const hostEditorRef = ref<InstanceType<typeof HostEditor> | null>(null);

function showEditDialog(host: HostDto) {
  hostEditorRef.value?.open(host);
}

const hostsTableRef = ref<InstanceType<typeof Table> | null>(null);

async function onHostUpdated() {
  await hostsTableRef.value?.reloadHosts();
}
</script>
