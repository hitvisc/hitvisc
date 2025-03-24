<template>
  <div class="card library-card">
    <div class="card-header">
      <h3 class="mb-0">
        {{ ligand.name }}
        <span :class="['badge mx-1', getEntityStateClass(ligand.state)]">
          {{ $t(`entity.state.${ligand.state}`) }}
        </span>
      </h3>

      <div class="card-actions d-flex">
        <!--        <button class="btn-action" @click="emit('toggleFavourite')">-->
        <!--          <x-icon-->
        <!--            :icon="ligand.isFavourite ? 'icon-star-filled' : 'icon-star'"-->
        <!--            :size="24"-->
        <!--            :class="{-->
        <!--              'text-primary': ligand.isFavourite-->
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
              :disabled="!isOwner || !isLigandReady"
              @click="emit('edit')"
            >
              {{ $t('ligand.card.edit') }}
            </button>
            <button
              class="dropdown-item text-danger"
              :disabled="!isOwner"
              @click="emit('delete')"
            >
              {{ $t('ligand.card.delete') }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="card-body">
      <div class="list text-secondary">
        <div class="list-item">
          <x-icon
            icon="icon-accessible"
            :size="18"
            class="icon"
          />
          {{ $t('library.typeOfUseLabel') }}:
          <span class="text-body">
            {{ $t(`library.typeOfUse.${ligand.typeOfUse}`) }}
          </span>
        </div>
        <div class="list-item">
          <x-icon
            icon="icon-users"
            :size="18"
            class="icon"
          />
          {{ $t('ligand.authors') }}:
          <span class="text-body">
            {{ ligand.authors }}
          </span>
        </div>
        <div class="list-item">
          <x-icon
            icon="icon-copyright"
            :size="18"
            class="icon"
          />
          {{ $t('library.creator') }}:
          <span class="text-body">
            {{ ligand.creatorName }}
          </span>
        </div>
      </div>

      <p class="description description--scroll mt-2 text-body">
        {{ ligand.description }}
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { LibraryCardDto } from '~/app-modules/library/clients/dto/library.dto';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { getEntityStateClass } from '~/app-modules/core/helpers/entity';
import { EntityState } from '~/app-modules/core/enums/EntityState';

const emit = defineEmits<{
  toggleFavourite: [];
  edit: [];
  delete: [];
}>();

const props = defineProps<{
  ligand: LibraryCardDto;
}>();

const { ligand } = toRefs(props);

const usersStore = useIOC(UsersStoreProvider).getStore();

const isOwner = computed(() => ligand.value.creatorId === usersStore.currentUser?.id);
const isLigandReady = computed(() => ligand.value.state === EntityState.Ready);
</script>

<style lang="scss" scoped></style>
