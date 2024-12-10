<template>
  <div class="card">
    <div class="table-responsive">
      <table class="table card-table table-vcenter text-nowrap datatable">
        <thead>
          <tr>
            <th></th>

            <th>
              <span
                class="sortable-column"
                @click="updateSortBy(HostSortableColumn.Name)"
              >
                {{ $t('resources.name') }}
                <x-icon
                  class="icon icon-sm"
                  :class="sortBy.column === HostSortableColumn.Name ? '' : 'hidden'"
                  :icon="sortIcon"
                />
              </span>
            </th>

            <th class="w-1">
              <span
                class="sortable-column"
                @click="updateSortBy(HostSortableColumn.LastRequestAt)"
              >
                {{ $t('resources.lastRequestAt') }}
                <x-icon
                  class="icon icon-sm"
                  :class="sortBy.column === HostSortableColumn.LastRequestAt ? '' : 'hidden'"
                  :icon="sortIcon"
                />
              </span>
            </th>

            <th class="w-1">
              <span
                class="sortable-column"
                @click="updateSortBy(HostSortableColumn.TasksInProgress)"
              >
                {{ $t('resources.tasksInProgress') }}
                <x-icon
                  class="icon icon-sm"
                  :class="sortBy.column === HostSortableColumn.TasksInProgress ? '' : 'hidden'"
                  :icon="sortIcon"
                />
              </span>
            </th>

            <th class="w-1">
              <span
                class="sortable-column"
                @click="updateSortBy(HostSortableColumn.TasksCompleted)"
              >
                {{ $t('resources.tasksCompleted') }}
                <x-icon
                  class="icon icon-sm"
                  :class="sortBy.column === HostSortableColumn.TasksCompleted ? '' : 'hidden'"
                  :icon="sortIcon"
                />
              </span>
            </th>

            <th>
              {{ $t('resources.accessMode') }}
            </th>

            <th />
          </tr>
        </thead>

        <tbody>
          <template v-if="hosts.length > 0">
            <tr
              v-for="(host, idx) in hosts"
              :key="idx"
            >
              <td>
                <span class="text-muted">{{ filter.offset + idx + 1 }}.</span>
              </td>

              <td>{{ host.name }}</td>

              <td>
                {{ host.lastRequestAt ? $formatDate(host.lastRequestAt, 'MMM DD, YYYY') : 'n/a' }}
              </td>

              <td>{{ host.tasksInProgress }}</td>

              <td>{{ host.tasksCompleted }}</td>

              <td>
                <span :class="['badge', getResourceTypeOfUseClass(host.usageType)]">
                  {{ $t(`resources.accessModes.${host.usageType}`) }}
                </span>
              </td>

              <td class="w-1">
                <button
                  v-if="host.userId === currentUserId"
                  class="btn btn-ghost-secondary btn-sm"
                  @click="() => emit('edit', host)"
                >
                  <x-icon
                    icon="icon-pencil"
                    :size="18"
                  />
                </button>
              </td>
            </tr>
          </template>

          <template v-else>
            <tr class="hosts-table__not-found">
              <td colspan="6">{{ $t('resources.notFound') }}</td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>

    <div
      v-if="totalCount > 0"
      class="card-footer d-flex align-items-center"
    >
      <x-pagination
        v-model="currentPage"
        :total-count="totalCount"
        :has-label="true"
        :on-page="filter.limit"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { HostUsageType } from '../enums/HostUsageType';
import { HostClient } from '~/app-modules/resources/clients/host.client';
import { HostDto } from '~/app-modules/resources/clients/dto/host.dto';
import { HostSortableColumn } from '~/app-modules/resources/enums/HostSortableColumn';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';

const props = defineProps<{
  usageType: HostUsageType;
  showInactive: boolean;
}>();
const { usageType, showInactive } = toRefs(props);

const emit = defineEmits<{
  (_eventName: 'edit', _host: HostDto): void;
}>();

const usersStore = useIOC(UsersStoreProvider).getStore();
const hostClient = useIOC(HostClient);

const currentPage = ref(1);
const filter = reactive({
  offset: 0,
  limit: 10,
});

const sortBy = reactive<{ column: HostSortableColumn; order: 1 | -1 }>({
  column: HostSortableColumn.LastRequestAt,
  order: 1,
});

const sortIcon = computed(() => (sortBy.order === 1 ? 'icon-triangle' : 'icon-triangle-inverted'));

const currentUserId = computed(() => usersStore.currentUser?.id);

const totalCount = ref(0);
const hosts: Ref<HostDto[]> = ref([]);

defineExpose({
  reloadHosts,
});

await reloadHosts();

watch([currentPage, sortBy, showInactive], async () => {
  await reloadHosts();
});

async function reloadHosts() {
  filter.offset = (currentPage.value - 1) * filter.limit;
  const page = await hostClient.findHosts(
    filter.offset,
    filter.limit,
    usageType.value,
    sortBy.column,
    sortBy.order,
    showInactive.value,
  );
  totalCount.value = page.totalCount;
  hosts.value = page.hosts;
}

const getResourceTypeOfUseClass = (mode: HostUsageType) =>
  ({
    [HostUsageType.Public]: 'bg-green text-green-fg',
    [HostUsageType.Private]: 'bg-yellow text-yellow-fg',
    [HostUsageType.Test]: 'bg-purple text-purple-fg',
  })[mode];

function updateSortBy(column: HostSortableColumn) {
  if (sortBy.column === column) {
    sortBy.order *= -1;
  } else {
    sortBy.column = column;
    sortBy.order = 1;
  }
  currentPage.value = 1;
}
</script>

<style lang="scss" scoped>
.hosts-table {
  &__not-found {
    text-align: center;
  }
}

th {
  user-select: none;
}

.sortable-column {
  cursor: pointer;

  .icon {
    transition: none;
    margin-left: 4px;

    &.hidden {
      visibility: hidden;
    }
  }

  &:hover {
    color: var(--tblr-blue-darken);
  }
}
</style>
