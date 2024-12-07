<template>
  <div class="card">
    <div class="card-header">
      <h3 class="mb-0">
        {{ target.name }}
        <span :class="['badge mx-1', getEntityStateClass(target.state)]">
          {{ $t(`entity.state.${target.state}`) }}
        </span>
      </h3>

      <div class="card-actions d-flex">
        <!--        <button class="btn-action" @click="emit('toggleFavourite')">-->
        <!--          <x-icon-->
        <!--            :icon="target.isFavourite ? 'icon-star-filled' : 'icon-star'"-->
        <!--            :size="24"-->
        <!--            :class="{-->
        <!--              'text-primary': target.isFavourite-->
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
              {{ $t('target.card.edit') }}
            </button>
            <button
              class="dropdown-item text-danger"
              :disabled="!isOwner"
              @click="emit('delete')"
            >
              {{ $t('target.card.delete') }}
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
            {{ $t(`library.typeOfUse.${target.typeOfUse}`) }}
          </span>
        </div>
        <div class="list-item">
          <x-icon
            icon="icon-users"
            :size="18"
            class="icon"
          />
          {{ $t('target.authors') }}:
          <span class="text-body">
            {{ target.authors }}
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
            {{ target.creatorName }}
          </span>
        </div>
      </div>

      <p class="description description--scroll mt-2 text-body">
        {{ target.description }}
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { TargetCardDto } from '~/app-modules/library/clients/dto/target.dto';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { getEntityStateClass } from '~/app-modules/core/helpers/entity';

const emit = defineEmits<{
  toggleFavourite: [];
  edit: [];
  delete: [];
}>();

const props = defineProps<{
  target: TargetCardDto;
}>();

const { target } = toRefs(props);

const usersStore = useIOC(UsersStoreProvider).getStore();

const isOwner = computed(() => target.value.creatorId === usersStore.currentUser?.id);
</script>

<style lang="scss" scoped></style>
