<template>
  <x-modal
    v-model="isVisible"
    :title="$t('projects.deletor.title')"
    width="500px"
    :has-footer="false"
  >
    <p>
      {{ $t('projects.deletor.text', { name: searchName }) }}
    </p>

    <div class="form-footer">
      <button
        type="button"
        class="btn btn-ghost-secondary w-50"
        @click="() => reset()"
      >
        {{ $t('projects.deletor.cancelBtn') }}
      </button>

      <button
        type="button"
        class="btn btn-danger w-50"
        @click="() => confirmDelete()"
      >
        {{ $t('projects.deletor.submitBtn') }}
      </button>
    </div>
  </x-modal>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { SearchService } from '~/app-modules/projects/services/search.service';

const emit = defineEmits<{
  deleted: [];
}>();

const { t } = useI18n();

const isVisible = ref(false);
const searchId = ref(0);
const searchName = ref('');

const searchService = useIOC(SearchService);

async function confirmDelete() {
  try {
    await searchService.deleteSearch(searchId.value);
    emit('deleted');
    reset();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка удаления проекта');
    } else {
      throw error;
    }
  }
}

function open(id: number, name: string) {
  searchId.value = id;
  searchName.value = name;
  isVisible.value = true;
}

function reset() {
  isVisible.value = false;
}

defineExpose({
  open,
});
</script>

<style lang="scss" scoped>
.form-footer {
  display: flex;
  column-gap: 12px;
  justify-content: space-between;
}
</style>
