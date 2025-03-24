<template>
  <x-modal
    v-model="isVisible"
    :title="$t('target.editor.title')"
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
        <label class="form-label required">{{ $t('target.name') }}</label>

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
        <label class="form-label">{{ $t('target.description') }}</label>

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

      <div class="mb-3">
        <label class="form-label required">{{ $t('target.authors') }}</label>

        <input
          v-model="authors"
          type="text"
          class="form-control"
          :class="{
            'is-invalid': errors.authors,
          }"
          autocomplete="off"
        />

        <x-error-message
          v-if="errors.authors"
          :message="errors.authors"
          class="invalid-feedback"
        />
      </div>

      <div class="mb-3">
        <label class="form-label">{{ $t('target.source') }}</label>

        <input
          v-model="source"
          type="text"
          class="form-control"
          :class="{
            'is-invalid': errors.source,
          }"
          autocomplete="off"
        />

        <x-error-message
          v-if="errors.source"
          :message="errors.source"
          class="invalid-feedback"
        />
      </div>

      <div class="mb-3">
        <label class="form-label">{{ $t('library.typeOfUseLabel') }}</label>

        <select
          v-model="typeOfUse"
          class="form-control"
          :class="{
            'is-invalid': errors.typeOfUse,
          }"
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

        <x-error-message
          v-if="errors.typeOfUse"
          :message="errors.typeOfUse"
          class="invalid-feedback"
        />
      </div>

      <div class="form-footer">
        <button
          type="submit"
          class="btn btn-primary w-100"
        >
          {{ $t('target.editor.submitBtn') }}
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
import { TargetService } from '~/app-modules/library/services/target.service';
import { TargetDto, TargetCardDto } from '~/app-modules/library/clients/dto/target.dto';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';

const emit = defineEmits<{
  updated: [];
}>();

const isVisible = ref(false);

const { t } = useI18n();

const typeOfUseOptions = Object.values(TypeOfUse).map((value) => ({
  value,
  label: t(`library.typeOfUse.${value}`),
}));


const updateTargetSchema = computed(() =>
  z.object({
    name: z
      .string({ required_error: t('validation.required') })
      .min(1, { message: t('validation.required') }),
    description: z
      .string({ required_error: t('validation.required') })
      .max(2000, { message: t('validation.maxLength', { maxLength: 2000 }) }),
    authors: z
      .string({ required_error: t('validation.required') })
      .min(1, { message: t('validation.required') }),
    source: z.string({ required_error: t('validation.required') }),
    typeOfUse: z.nativeEnum(TypeOfUse),
  }),
);

const validationSchema = computed(() =>
  toTypedSchema(updateTargetSchema.value),
);

const { handleSubmit, errors, resetForm } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    description: '',
    authors: '',
    source: '',
    typeOfUse: TypeOfUse.Restricted,
  },
});

const targetId = ref(0);
const { value: name } = useField('name');
const { value: description } = useField('description');
const { value: authors } = useField('authors');
const { value: source } = useField('source');
const { value: typeOfUse } = useField('typeOfUse');

const targetService = useIOC(TargetService);

const onSubmit = handleSubmit(async (values) => {
  try {
    const dto: TargetDto = {
      name: values.name,
      description: values.description,
      authors: values.authors,
      source: values.source,
      typeOfUse: values.typeOfUse,
    };
    await targetService.updateTarget(targetId.value, dto);
    emit('updated');
    reset();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка обновления мишени');
    } else {
      throw error;
    }
  }
});

function open(target: TargetCardDto) {
  targetId.value = target.id;
  name.value = target.name;
  description.value = target.description;
  authors.value = target.authors;
  source.value = target.source;
  typeOfUse.value = target.typeOfUse;
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
