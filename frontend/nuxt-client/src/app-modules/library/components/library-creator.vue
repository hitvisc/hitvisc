<template>
  <x-modal
    v-model="isVisible"
    :title="$t('ligand.creator.title')"
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
        <label class="form-label required">{{ $t('ligand.name') }}</label>

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
        <label class="form-label">{{ $t('ligand.description') }}</label>

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
        <label class="form-label required">{{ $t('ligand.authors') }}</label>

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
        <label class="form-label">{{ $t('ligand.source') }}</label>

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

      <div class="mb-3">
        <label class="form-label required">{{ $t('ligand.fileSourceLabel') }}</label>

        <div class="row g-4">
          <div class="col-auto">
            <label
              v-for="option in fileSourceOptions"
              :key="option.value"
              class="form-check"
            >
              <input
                v-model="fileSource"
                class="form-check-input"
                type="radio"
                :value="option.value"
              />
              <span class="form-check-label">
                {{ option.label }}
              </span>
            </label>
          </div>
          <div class="col">
            <template v-if="fileSource === LibrarySource.Url">
              <input
                v-model="fileUrl"
                type="text"
                class="form-control"
                :class="{
                  'is-invalid': errors.fileUrl,
                }"
                autocomplete="off"
              />

              <x-error-message
                v-if="errors.fileUrl"
                :message="errors.fileUrl"
                class="invalid-feedback"
              />
            </template>

            <div
              v-if="fileSource === LibrarySource.File"
              class="input-icon"
            >
              <input
                type="file"
                :disabled="isUploadingLibraryFile"
                class="form-control"
                :class="{
                  'is-invalid': errors.fileId || !!ligandsLibraryFileUploadError,
                }"
                multiple
                @change="handleLigandsLibraryFile"
              />

              <span
                v-if="isUploadingLibraryFile"
                class="input-icon-addon"
              >
                <div class="spinner-border spinner-border-sm text-secondary" />
              </span>

              <x-error-message
                v-if="errors.fileId"
                :message="errors.fileId"
                class="invalid-feedback"
              />
              <x-error-message
                v-if="ligandsLibraryFileUploadError"
                :message="ligandsLibraryFileUploadError"
                class="invalid-feedback"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="form-footer">
        <button
          type="submit"
          class="btn btn-primary w-100"
        >
          {{ $t('ligand.creator.submitBtn') }}
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
import { LibraryService } from '~/app-modules/library/services/library.service';
import { createLibraryDto } from '~/app-modules/library/clients/dto/library.dto';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { LibrarySource } from '~/app-modules/library/enums/LibrarySource';
import { parseUploadFileErrorMessage } from '~/app-modules/core/helpers/files';

const emit = defineEmits<{
  created: [];
}>();

const isVisible = ref(false);

const { t } = useI18n();

const typeOfUseOptions = Object.values(TypeOfUse).map((value) => ({
  value,
  label: t(`library.typeOfUse.${value}`),
}));

const fileSourceOptions = Object.values(LibrarySource).map((value) => ({
  value,
  label: t(`ligand.fileSource.${value}`),
}));

const ligandsLibraryFileUploadError = ref('');

const isUploadingLibraryFile = ref(false);

const createTargetSchema = computed(() =>
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

const fileSourceSchema = computed(() =>
  z
    .object({
      fileSource: z.nativeEnum(LibrarySource),
      fileUrl: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .nullable(),
      fileId: z.string({ required_error: t('validation.required') }).nullable(),
    })
    .superRefine((data, ctx) => {
      if (data.fileSource === LibrarySource.Url && !data.fileUrl) {
        ctx.addIssue({
          path: ['fileUrl'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (data.fileSource === LibrarySource.File && !data.fileId) {
        ctx.addIssue({
          path: ['fileId'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
    }),
);

const validationSchema = computed(() =>
  toTypedSchema(z.intersection(createTargetSchema.value, fileSourceSchema.value)),
);

const { handleSubmit, errors, resetForm } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    description: '',
    authors: '',
    source: '',
    typeOfUse: TypeOfUse.Restricted,
    fileSource: LibrarySource.File,
    fileUrl: null,
    fileId: null,
  },
});

const { value: name } = useField('name');
const { value: description } = useField('description');
const { value: authors } = useField('authors');
const { value: source } = useField('source');
const { value: typeOfUse } = useField('typeOfUse');
const { value: fileSource } = useField('fileSource');
const { value: fileUrl } = useField('fileUrl');
const { value: fileId } = useField('fileId');

async function handleLigandsLibraryFile(event: Event & { target: HTMLInputElement }) {
  ligandsLibraryFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    fileId.value = null;
    return;
  }
  try {
    isUploadingLibraryFile.value = true;
    fileId.value = await libraryService.uploadLibraryFile(file);
  } catch (error) {
    ligandsLibraryFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingLibraryFile.value = false;
  }
}

const libraryService = useIOC(LibraryService);
const onSubmit = handleSubmit(async (values) => {
  try {
    const dto: createLibraryDto = {
      name: values.name,
      description: values.description,
      authors: values.authors,
      source: values.source,
      typeOfUse: values.typeOfUse,
      fileSource: values.fileSource,
      fileId: values.fileId,
      fileUrl: values.fileUrl,
    };
    await libraryService.createLibrary(dto);
    emit('created');
    reset();
  } catch (error) {
    useToast().info(t('inWork.title'));
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка создания коллекции лигандов');
    } else {
      throw error;
    }
  }
});

function open() {
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
