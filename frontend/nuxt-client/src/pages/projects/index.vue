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
              {{ $t('features.projects') }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="container-xl">
      <div class="row">
        <div class="col-12">
          <router-link to="/projects/new">
            <button class="btn btn-primary mb-3">
              <x-icon
                icon="icon-plus"
                :size="18"
              ></x-icon>

              {{ $t('projects.addBtn') }}
            </button>
          </router-link>

          <projects-editor
            ref="searchEditorRef"
            @updated="onSearchUpdated"
          />

          <div class="library-items">
            <projects-search-card
              v-for="project in projects"
              :key="project.id"
              :search="project"
              @edit="onEdit(project)"
              @delete="onDelete(project)"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { SearchCardDto } from '~/app-modules/projects/clients/dto/search.dto';
import { SearchService } from '~/app-modules/projects/services/search.service';
import SearchEditor from '~/app-modules/projects/components/editor.vue';

const projects: Ref<SearchCardDto[]> = ref([]);

const searchService = useIOC(SearchService);
const { t } = useI18n();

fetchProjects();

async function fetchProjects() {
  try {
    projects.value = await searchService.getSearches();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения проектов');
    } else {
      throw error;
    }
  }
}

const searchEditorRef = ref<InstanceType<typeof SearchEditor> | null>(null);

function onEdit(_search: SearchCardDto) {
  searchEditorRef.value?.open(_search);
}

async function onDelete(_search: SearchCardDto) {
  useToast().info(t('inWork.title'));
  await fetchProjects();
}

async function onSearchUpdated() {
  await fetchProjects();
}
</script>
