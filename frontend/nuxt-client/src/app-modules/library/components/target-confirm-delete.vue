<template>
  <x-modal
    v-model="isVisible"
    :title="$t('target.deletor.title')"
    width="500px"
    :has-footer="false"
  >
    <p>
      {{ $t('target.deletor.text', { name: targetName }) }}
    </p>

    <div class="form-footer">
      <button
        type="button"
        class="btn btn-ghost-secondary w-50"
        @click="() => reset()"
      >
        {{ $t('target.deletor.cancelBtn') }}
      </button>

      <button
        type="button"
        class="btn btn-danger w-50"
        @click="() => confirmDelete()"
      >
        {{ $t('target.deletor.submitBtn') }}
      </button>
    </div>
  </x-modal>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { TargetService } from '~/app-modules/library/services/target.service';

const emit = defineEmits<{
  deleted: [];
}>();

const { t } = useI18n();

const isVisible = ref(false);
const targetId = ref(0);
const targetName = ref('');

const targetService = useIOC(TargetService);

async function confirmDelete() {
  try {
    await targetService.deleteTarget(targetId.value);
    emit('deleted');
    reset();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка удаления мишени');
    } else {
      throw error;
    }
  }
}

function open(id: number, name: string) {
  targetId.value = id;
  targetName.value = name;
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
