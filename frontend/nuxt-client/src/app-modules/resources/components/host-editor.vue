<template>
  <x-modal
    v-model="isVisible"
    :title="$t('resources.editor.title')"
    width="600px"
    :has-footer="false"
    @close="reset()"
  >
    <form
      autocomplete="off"
      novalidate
      @submit.prevent="onSubmit"
    >
      <div class="mb-3">
        <label class="form-label required">{{ $t('resources.name') }}</label>

        <input
          v-model="name"
          type="text"
          class="form-control"
          :class="{
            'is-invalid': errors.name,
          }"
          autocomplete="off"
        />

        <x-error-message
          v-if="errors.name"
          :message="errors.name"
          class="invalid-feedback"
        />
      </div>

      <div class="mb-3">
        <label class="form-label">{{ $t('resources.accessMode') }}</label>

        <select
          v-model="usageType"
          class="form-control"
          :class="{
            'is-invalid': errors.usageType,
          }"
          autocomplete="off"
        >
          <option
            v-for="option in usageTypeOptions"
            :key="option.value"
            :value="option.value"
          >
            {{ option.label }}
          </option>
        </select>

        <x-error-message
          v-if="errors.usageType"
          :message="errors.usageType"
          class="invalid-feedback"
        />
      </div>

      <div class="form-footer">
        <button
          type="submit"
          class="btn btn-primary w-100"
        >
          {{ $t('resources.editor.submitBtn') }}
        </button>
      </div>
    </form>
  </x-modal>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { z } from 'zod';
import { toTypedSchema } from '@vee-validate/zod';
import { useField, useForm } from 'vee-validate';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';
import { HostClient } from '~/app-modules/resources/clients/host.client';
import { HostDto } from '~/app-modules/resources/clients/dto/host.dto';

const emit = defineEmits<{
  updated: [];
}>();

const isVisible = ref(false);

const { t } = useI18n();

const usageTypeOptions = Object.values(HostUsageType).map((value) => ({
  value,
  label: t(`resources.accessModes.${value}`),
}));

const hostSchema = computed(() =>
  z.object({
    name: z
      .string({ required_error: t('validation.required') })
      .regex(/^[0-9a-zA-Zа-яА-ЯёË:-]*$/, { message: t('validation.invalidFormat') })
      .min(1, { message: t('validation.required') })
      .max(10, { message: t('validation.maxLength', { maxLength: 11 }) }),
    usageType: z.nativeEnum(HostUsageType),
  }),
);

const validationSchema = computed(() => toTypedSchema(hostSchema.value));

const { handleSubmit, errors, resetForm } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    usageType: HostUsageType.Private,
  },
});

const hostId = ref(0);
const { value: name } = useField('name');
const { value: usageType } = useField('usageType');

const hostClient = useIOC(HostClient);

const onSubmit = handleSubmit(async (values) => {
  try {
    await hostClient.updateHost(hostId.value, values.name, values.usageType);
    emit('updated');
    reset();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка редактирования');
    } else {
      throw error;
    }
  }
});

function open(host: HostDto) {
  hostId.value = host.id;
  name.value = host.name;
  usageType.value = host.usageType;
  isVisible.value = true;
}

function reset() {
  isVisible.value = false;
  resetForm();
}

defineExpose({
  open,
});
</script>

<style lang="scss" scoped></style>
