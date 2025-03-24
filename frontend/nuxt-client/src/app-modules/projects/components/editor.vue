<template>
  <x-modal
    v-model="isVisible"
    :title="$t('projects.editor.title')"
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
        <label class="form-label required">{{ $t('projects.editor.name') }}</label>

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
        <label class="form-label">{{ $t('projects.typeOfUseLabel') }}</label>

        <select
          v-model="typeOfUse"
          class="form-control"
          autocomplete="off"
        >
          <option
            v-for="option in typeOfUseOptions"
            :key="option.value"
            :value="option.value"
          >
            {{ option.label }}
          </option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label">{{ $t('projects.editor.description') }}</label>

        <textarea
          v-model="description"
          type="text"
          class="form-control"
          rows="3"
          :class="{
            'is-invalid': errors.description,
          }"
          autocomplete="off"
        />

        <x-error-message
          v-if="errors.description"
          :message="errors.description"
          class="invalid-feedback"
        />
      </div>

      <div class="form-footer">
        <button
          type="submit"
          class="btn btn-primary w-100"
        >
          {{ $t('projects.editor.submitBtn') }}
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
import { SearchService } from '~/app-modules/projects/services/search.service';
import { SearchCardDto, UpdateSearchDto } from '~/app-modules/projects/clients/dto/search.dto';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';

const { t } = useI18n();

const emit = defineEmits<{
  updated: [];
}>();

const isVisible = ref(false);

const typeOfUseOptions = Object.values(TypeOfUse).map((value) => ({
  value,
  label: t(`projects.typeOfUse.${value}`),
}));

const editSearchSchema = computed(() =>
  z.object({
    name: z
      .string({ required_error: t('validation.required') })
      .min(1, { message: t('validation.required') }),
    description: z
      .string({ required_error: t('validation.required') })
      .max(2000, { message: t('validation.maxLength', { maxLength: 2000 }) }),
  }),
);

const validationSchema = computed(() => toTypedSchema(editSearchSchema.value));

const { handleSubmit, errors, resetForm } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    typeOfUse: TypeOfUse.Private,
    description: '',
  },
});

const searchId = ref(0);
const { value: name } = useField('name');
const { value: typeOfUse } = useField<string>('typeOfUse');
const { value: description } = useField<string>('description');

const projectsService = useIOC(SearchService);

const onSubmit = handleSubmit(async (values) => {
  try {
    const dto: UpdateSearchDto = {
      name: name.value,
      typeOfUse: typeOfUse.value,
      description: description.value,
    };
    await projectsService.updateSearch(searchId.value, dto);
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

function open(search: SearchCardDto) {
  searchId.value = search.id;
  name.value = search.name;
  typeOfUse.value = search.typeOfUse;
  description.value = search.description;
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
