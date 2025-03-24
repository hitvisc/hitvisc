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
              {{ $t('features.projects') }}:
              {{ $t('projects.results') }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <projects-editor
      ref="searchEditorRef"
      @updated="onSearchUpdated"
    />

    <div class="container-xl">
      <div class="row">
        <div class="col-12">
          <projects-search-card
            v-if="search"
            :search="search"
            :preview="false"
            @edit="onEdit(search)"
            @delete="onDelete(search)"
          />
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

const search: Ref<SearchCardDto | undefined> = ref();

const { searchId }: { searchId?: number } = useRoute().params;

if (!searchId) {
  useRouter().push('/project');
}

const searchService = useIOC(SearchService);
const { t } = useI18n();

fetchProjects();

async function fetchProjects() {
  try {
    search.value = await searchService.getSearch(searchId!);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      showError({
        statusCode: error?.response?.status ?? 500,
        message: 'Ошибка получения проекта',
      });
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
