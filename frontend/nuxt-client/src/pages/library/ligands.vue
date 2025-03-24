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
              {{ $t('ligand.feature') }}
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
            @click="openLibraryCreator()"
          >
            <x-icon
              icon="icon-plus"
              :size="18"
            ></x-icon>

            {{ $t('ligand.addBtn') }}
          </button>

          <library-creator
            ref="libraryCreatorRef"
            @created="() => fetchLibraries()"
          />

          <library-editor
            ref="libraryEditorRef"
            @updated="() => fetchLibraries()"
          />

          <library-confirm-delete
            ref="libraryConfirmDeleteRef"
            @deleted="() => fetchLibraries()"
          />

          <div class="library-items">
            <library-card
              v-for="library in libraries"
              :key="library.id"
              :ligand="library"
              @toggle-favourite="onToggleFavourite(library)"
              @edit="onEdit(library)"
              @delete="onDelete(library)"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import axios from 'axios';
import LibraryCreator from '~/app-modules/library/components/library-creator.vue';
import { LibraryCardDto } from '~/app-modules/library/clients/dto/library.dto';
import { LibraryService } from '~/app-modules/library/services/library.service';
import LibraryEditor from '~/app-modules/library/components/library-editor.vue';
import LibraryConfirmDelete from '~/app-modules/library/components/library-confirm-delete.vue';

const libraryCreatorRef = ref<InstanceType<typeof LibraryCreator> | null>(null);

const libraries: Ref<LibraryCardDto[]> = ref([]);

const libraryService = useIOC(LibraryService);
const { t } = useI18n();

fetchLibraries();

async function fetchLibraries() {
  try {
    libraries.value = await libraryService.getLibraries();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения коллекций лигандов');
    } else {
      throw error;
    }
  }
}

function openLibraryCreator() {
  libraryCreatorRef.value?.open();
}

function onToggleFavourite(library: LibraryCardDto) {
  library.isFavourite = !library.isFavourite;
}

const libraryEditorRef = ref<InstanceType<typeof LibraryEditor> | null>(null);

function onEdit(_library: LibraryCardDto) {
  libraryEditorRef.value?.open(_library);
}

const libraryConfirmDeleteRef = ref<InstanceType<typeof LibraryConfirmDelete> | null>(null);

async function onDelete(_library: LibraryCardDto) {
  libraryConfirmDeleteRef.value?.open(_library.id, _library.name);
}
</script>
