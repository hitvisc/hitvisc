<template>
  <div class="card">
    <div class="card-header">
      <h3 class="mb-0">
        <router-link
          v-if="preview"
          :to="`/projects/${search.id}`"
        >
          {{ search.name }}
          <span :class="['badge mx-1', getEntityStateClass(search.state)]">
            {{ $t(`entity.state.${search.state}`) }}
          </span>
        </router-link>
        <template v-else>
          {{ search.name }}
          <span :class="['badge mx-1', getEntityStateClass(search.state)]">
            {{ $t(`entity.state.${search.state}`) }}
          </span>
        </template>
      </h3>

      <div class="card-actions d-flex">
        <!--        <button class="btn-action" @click="isFavorite = !isFavorite">-->
        <!--          <x-icon-->
        <!--            :icon="isFavorite ? 'icon-star-filled' : 'icon-star'"-->
        <!--            :size="24"-->
        <!--            :class="{-->
        <!--              'text-primary': isFavorite-->
        <!--            }"-->
        <!--          />-->
        <!--        </button>-->
        <div class="dropdown">
          <button
            class="btn-action dropdown-toggle"
            data-bs-toggle="dropdown"
            aria-haspopup="true"
            aria-expanded="false"
          >
            <x-icon
              icon="icon-cog"
              :size="24"
            />
          </button>
          <div class="dropdown-menu dropdown-menu-end">
            <button
              class="dropdown-item"
              :disabled="!isOwner"
              @click="emit('edit')"
            >
              {{ $t('projects.card.edit') }}
            </button>
            <button
              class="dropdown-item text-danger"
              :disabled="!isOwner"
              @click="emit('delete')"
            >
              {{ $t('projects.card.delete') }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="card-body">
      <div class="row">
        <div
          class="col-12"
          :class="{
            'col-lg-6': !preview,
          }"
        >
          <div class="list text-secondary">
            <div class="list-item">
              <x-icon
                icon="icon-target"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.target') }}:
              <span class="text-body">
                {{ search.targetName }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-ligand"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.ligandsLibrary') }}:
              <span class="text-body">
                {{ search.libraryName }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-application"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.application') }}:
              <span class="text-body">
                {{ $t(`projects.creator.applications.${search.applicationId}`) }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-hit-criterion"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.hitSelectionCriterion') }}:
              <span class="text-body">
                {{ $t(`projects.creator.${search.hitSelectionCriterion}`) }},
                {{ search.hitSelectionValue }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-stop-criterion"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.stoppingCriterion') }}:
              <span class="text-body">
                {{ $t(`projects.creator.${search.stoppingCriterion}`) }},
                {{ search.stoppingValue }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-resource"
                :size="18"
                class="icon"
              />
              {{ $t('projects.creator.computationalResources') }}:
              <span class="text-body">
                {{ $t(`projects.creator.resourcesType.${search.resourcesType}`) }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-accessible"
                :size="18"
                class="icon"
              />
              {{ $t('projects.typeOfUseLabel') }}:
              <span class="text-body">
                {{ $t(`projects.typeOfUse.${search.typeOfUse}`) }}
              </span>
            </div>
            <div class="list-item">
              <x-icon
                icon="icon-copyright"
                :size="18"
                class="icon"
              />
              {{ $t('projects.createdBy') }}:
              <span class="text-body">
                {{ search.creatorName }}
              </span>
            </div>
          </div>

          <p class="description description--scroll mt-2 text-body">
            {{ search.description }}
          </p>
        </div>

        <div
          v-if="!preview"
          class="col-12 col-lg-6"
        >
          <div class="row align-items-center py-1 result-link">
            <div class="col text-truncate">{{ $t('projects.allHits') }}:</div>
            <div class="col-auto">
              <button
                :disabled="!search.isCompleted"
                class="btn"
                :class="{
                  'btn-primary': search.isCompleted,
                  'btn-secondary': !search.isCompleted,
                }"
                @click="() => onSearchResultsDownload('all')"
              >
                {{ $t('common.download') }}
              </button>
            </div>
          </div>

          <div class="row align-items-center py-1 result-link">
            <div class="col text-truncate">{{ $t('projects.divHits') }}:</div>
            <div class="col-auto">
              <button
                :disabled="!search.isCompleted"
                class="btn"
                :class="{
                  'btn-primary': search.isCompleted,
                  'btn-secondary': !search.isCompleted,
                }"
                @click="() => onSearchResultsDownload('div')"
              >
                {{ $t('common.download') }}
              </button>
            </div>
          </div>

          <div class="row align-items-center py-1 result-link">
            <div class="col text-truncate">{{ $t('projects.visHits') }}:</div>
            <div class="col-auto">
              <button
                :disabled="!search.isCompleted"
                class="btn"
                :class="{
                  'btn-primary': search.isCompleted,
                  'btn-secondary': !search.isCompleted,
                }"
                @click="() => onSearchResultsDownload('viz')"
              >
                {{ $t('common.download') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="preview"
      class="card-footer card-footer-transparent"
    >
      <button
        :disabled="!search.isCompleted"
        class="btn w-100"
        :class="{
          'btn-primary': search.isCompleted,
          'btn-secondary': !search.isCompleted,
        }"
        @click="() => useRouter().push(`/projects/${search.id}`)"
      >
        <x-icon
          icon="icon-search-results"
          :size="18"
          class="icon"
        />
        {{ $t('projects.results') }}
      </button>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { SearchCardDto } from '~/app-modules/projects/clients/dto/search.dto';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { SearchClient } from '~/app-modules/projects/clients/search.client';
import { getEntityStateClass } from '~/app-modules/core/helpers/entity';

const emit = defineEmits<{
  toggleFavourite: [];
  edit: [];
  delete: [];
}>();

const props = withDefaults(
  defineProps<{
    search: SearchCardDto;
    preview?: boolean;
  }>(),
  {
    preview: true,
  },
);

const { search, preview } = toRefs(props);

const searchClient = useIOC(SearchClient);
const usersStore = useIOC(UsersStoreProvider).getStore();

const isOwner = computed(() => search.value.creatorId === usersStore.currentUser?.id);

async function onSearchResultsDownload(type: string) {
  const userId = usersStore.currentUser?.id;
  try {
    const isResultAvailable = await searchClient.isResultAvailable(search.value.id, type, userId);
    if (isResultAvailable) {
      const url = new URL(
        `/api/search/${search.value.id}/results/hits/${type}?userId=${userId}`,
        useRuntimeConfig().public.apiBoincaasBaseUrl,
      ).href;
      window.open(url, '_blank');
    } else {
      useToast().error('Результат не доступен для скачивания');
    }
  } catch (e) {
    useToast().error('Результат не доступен для скачивания');
  }
}

// const isFavorite = ref(false);
</script>

<style lang="scss" scoped>
.result-link {
  font-size: 16px;

  &:hover {
    background-color: rgba(var(--tblr-secondary-rgb), 0.08);
  }
}
</style>
