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
              {{ $t('features.library') }}:
              {{ $t('target.feature') }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="container-xl">
      <div class="row">
        <div class="col-12">
          <button
            class="btn btn-primary mb-3"
            @click="openTargetCreator()"
          >
            <x-icon
              icon="icon-plus"
              :size="18"
            ></x-icon>

            {{ $t('target.addBtn') }}
          </button>

          <library-target-creator
            ref="targetCreatorRef"
            @created="() => fetchTargets()"
          />


          <library-target-editor
            ref="targetEditorRef"
            @updated="() => fetchTargets()"
          />

          <div class="library-items">
            <library-target-card
              v-for="target in targets"
              :key="target.id"
              :target="target"
              @toggle-favourite="onToggleFavourite(target)"
              @edit="onEdit(target)"
              @delete="onDelete(target)"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import axios from 'axios';
import TargetCreator from '~/app-modules/library/components/target-creator.vue';
import { TargetCardDto } from '~/app-modules/library/clients/dto/target.dto';
import { TargetService } from '~/app-modules/library/services/target.service';
import TargetEditor from '~/app-modules/library/components/target-editor.vue';

const targetCreatorRef = ref<InstanceType<typeof TargetCreator> | null>(null);

const targets: Ref<TargetCardDto[]> = ref([]);

const targetService = useIOC(TargetService);
const { t } = useI18n();

fetchTargets();

async function fetchTargets() {
  try {
    targets.value = await targetService.getTargets();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения мишеней');
    } else {
      throw error;
    }
  }
}

function openTargetCreator() {
  targetCreatorRef.value?.open();
}

function onToggleFavourite(target: TargetCardDto) {
  target.isFavourite = !target.isFavourite;
}

const targetEditorRef = ref<InstanceType<typeof TargetEditor> | null>(null);

function onEdit(_target: TargetCardDto) {
  targetEditorRef.value?.open(_target);
}

async function onDelete(_target: TargetCardDto) {
  useToast().info(t('inWork.title'));
  await fetchTargets();
}
</script>
