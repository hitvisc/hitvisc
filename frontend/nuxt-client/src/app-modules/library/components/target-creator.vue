<template>
  <x-modal
    v-model="isVisible"
    :title="$t('target.creator.title')"
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

      <div class="mb-3">
        <label class="form-label required">{{ $t('target.pdbSourceLabel') }}</label>

        <div class="row g-4">
          <div class="col-auto">
            <label
              v-for="option in pdbSourceOptions"
              :key="option.value"
              class="form-check"
            >
              <input
                v-model="pdbSource"
                class="form-check-input"
                type="radio"
                :value="option.value"
              />
              <span class="form-check-label">
                {{ option.label }}
              </span>
            </label>
          </div>
          <div
            v-show="pdbSource === PdbSource.Id"
            class="col"
          >
            <input
              v-model="pdbId"
              type="text"
              class="form-control"
              :class="{
                'is-invalid': errors.pdbId,
              }"
              autocomplete="off"
            />

            <x-error-message
              v-if="errors.pdbId"
              :message="errors.pdbId"
              class="invalid-feedback"
            />
          </div>

          <div
            v-show="pdbSource === PdbSource.File"
            class="col"
          >
            <div class="input-icon">
              <input
                type="file"
                :disabled="isUploadingPdbFile"
                class="form-control"
                :class="{
                  'is-invalid': errors.pdbFileId || !!pdbFileUploadError,
                }"
                @change="handlePdbFile"
              />

              <span
                v-if="isUploadingPdbFile"
                class="input-icon-addon"
              >
                <div class="spinner-border spinner-border-sm text-secondary" />
              </span>

              <x-error-message
                v-if="errors.pdbFileId"
                :message="errors.pdbFileId"
                class="invalid-feedback"
              />
              <x-error-message
                v-if="pdbFileUploadError"
                :message="pdbFileUploadError"
                class="invalid-feedback"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label">{{ $t('target.referenceLigands') }}</label>

        <div class="row g-4">
          <div class="col-auto">
            <label class="form-check">
              <input
                v-model="extractReferenceLigands"
                class="form-check-input"
                type="checkbox"
              />
              <span class="form-check-label">
                {{ $t('target.creator.extractAutomatically') }}
              </span>
            </label>
          </div>

          <div class="col">
            <div class="input-icon">
              <input
                v-if="!extractReferenceLigands"
                type="file"
                :disabled="isUploadingReferenceLigandsFile"
                multiple
                class="form-control"
                :class="{
                  'is-invalid': errors.referenceLigandsFileId || !!referenceLigandsFileUploadError,
                }"
                @change="handleReferenceLigandFile"
              />

              <span
                v-if="isUploadingReferenceLigandsFile"
                class="input-icon-addon"
              >
                <div class="spinner-border spinner-border-sm text-secondary" />
              </span>

              <x-error-message
                v-if="errors.referenceLigandsFileId"
                :message="errors.referenceLigandsFileId"
                class="invalid-feedback"
              />
              <x-error-message
                v-if="referenceLigandsFileUploadError"
                :message="referenceLigandsFileUploadError"
                class="invalid-feedback"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="form-footer">
        <button
          :disabled="isUploadingPdbFile || isUploadingReferenceLigandsFile"
          type="submit"
          class="btn btn-primary w-100"
        >
          {{ $t('target.creator.submitBtn') }}
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
import { CreateTargetDto } from '~/app-modules/library/clients/dto/target.dto';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { PdbSource } from '~/app-modules/library/enums/PdbSource';
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

const pdbSourceOptions = Object.values(PdbSource).map((value) => ({
  value,
  label: t(`target.pdbSource.${value}`),
}));

const pdbFileUploadError = ref('');
const referenceLigandsFileUploadError = ref('');

const isUploadingPdbFile = ref(false);
const isUploadingReferenceLigandsFile = ref(false);

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

const referenceLigandSchema = computed(() =>
  z.object({
    extractReferenceLigands: z.boolean(),
    referenceLigandsFileId: z.string({ required_error: t('validation.required') }).nullable(),
  }),
);

const pdbSourceSchema = computed(() =>
  z
    .object({
      pdbSource: z.nativeEnum(PdbSource),
      pdbId: z
        .string({ required_error: t('validation.required') })
        .min(1, { message: t('validation.required') })
        .nullable(),
      pdbFileId: z.string({ required_error: t('validation.required') }).nullable(),
    })
    .superRefine((data, ctx) => {
      if (data.pdbSource === PdbSource.Id && !data.pdbId) {
        ctx.addIssue({
          path: ['pdbId'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (data.pdbSource === PdbSource.File && !data.pdbFileId) {
        ctx.addIssue({
          path: ['pdbFileId'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
    }),
);

const validationSchema = computed(() =>
  toTypedSchema(
    getSchemasIntersection(
      createTargetSchema.value,
      pdbSourceSchema.value,
      referenceLigandSchema.value,
    ),
  ),
);

const { handleSubmit, errors, resetForm } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    description: '',
    authors: '',
    source: '',
    typeOfUse: TypeOfUse.Restricted,
    pdbSource: PdbSource.File,
    pdbId: null,
    pdbFileId: null,
    extractReferenceLigands: true,
    referenceLigandsFileId: null,
  },
});

const { value: name } = useField('name');
const { value: description } = useField('description');
const { value: authors } = useField('authors');
const { value: source } = useField('source');
const { value: typeOfUse } = useField('typeOfUse');
const { value: pdbSource } = useField('pdbSource');
const { value: pdbId } = useField('pdbId');
const { value: pdbFileId } = useField('pdbFileId');
const { value: extractReferenceLigands } = useField('extractReferenceLigands');
const { value: referenceLigandsFileId } = useField('referenceLigandsFileId');

const targetService = useIOC(TargetService);

async function handlePdbFile(event: Event & { target: HTMLInputElement }) {
  pdbFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    pdbFileId.value = null;
    return;
  }
  try {
    isUploadingPdbFile.value = true;
    pdbFileId.value = await targetService.uploadPdbFile(file);
  } catch (error) {
    pdbFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingPdbFile.value = false;
  }
}

async function handleReferenceLigandFile(event: Event & { target: HTMLInputElement }) {
  referenceLigandsFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    referenceLigandsFileId.value = null;
    return;
  }
  try {
    isUploadingReferenceLigandsFile.value = true;
    referenceLigandsFileId.value = await targetService.uploadReferenceLigandFile(file);
  } catch (error) {
    referenceLigandsFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingReferenceLigandsFile.value = false;
  }
}

const onSubmit = handleSubmit(async (values) => {
  try {
    const dto: CreateTargetDto = {
      name: values.name,
      description: values.description,
      authors: values.authors,
      source: values.source,
      typeOfUse: values.typeOfUse,
      pdbSource: values.pdbSource,
      pdbFileId: values.pdbFileId,
      pdbId: values.pdbId,
      extractReferenceLigands: values.extractReferenceLigands,
      referenceLigandsFileId: values.referenceLigandsFileId,
    };
    await targetService.createTarget(dto);
    emit('created');
    reset();
  } catch (error) {
    useToast().info(t('inWork.title'));
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка создания мишени');
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
