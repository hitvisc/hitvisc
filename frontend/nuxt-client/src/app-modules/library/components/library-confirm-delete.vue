<template>
  <x-modal
    v-model="isVisible"
    :title="$t('ligand.deletor.title')"
    width="500px"
    :has-footer="false"
  >
    <p>
      {{ $t('ligand.deletor.text', { name: libraryName }) }}
    </p>

    <div class="form-footer">
      <button
        type="button"
        class="btn btn-secondary w-50"
        @click="() => reset()"
      >
        {{ $t('ligand.deletor.cancelBtn') }}
      </button>

      <button
        type="button"
        class="btn btn-danger w-50"
        @click="() => confirmDelete()"
      >
        {{ $t('ligand.deletor.submitBtn') }}
      </button>
    </div>
  </x-modal>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { LibraryService } from '~/app-modules/library/services/library.service';

const emit = defineEmits<{
  deleted: [];
}>();

const { t } = useI18n();

const isVisible = ref(false);
const libraryId = ref(0);
const libraryName = ref('');

const libraryService = useIOC(LibraryService);

async function confirmDelete() {
  try {
    await libraryService.deleteLibrary(libraryId.value);
    emit('deleted');
    reset();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка удаления коллекции лигандов');
    } else {
      throw error;
    }
  }
}

function open(id: number, name: string) {
  libraryId.value = id;
  libraryName.value = name;
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
