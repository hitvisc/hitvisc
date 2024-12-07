<template>
  <div class="pagination-container">
    <div
      v-if="hasLabel"
      class="text-muted"
    >
      {{ firstVisibleRow }}-{{ lastVisibleRow }} {{ $t('pagination.of') }}
      {{ totalCount }}
    </div>

    <ul
      v-if="totalCount > onPage"
      class="pagination m-1"
    >
      <li
        class="page-item"
        :class="currentPage === 1 ? 'disabled' : ''"
      >
        <a
          class="page-link"
          tabindex="-1"
          aria-disabled="true"
          @click="goToPrevPage()"
        >
          <x-icon
            icon="icon-chevron-left"
            class="icon"
            :size="14"
          ></x-icon>

          {{ $t('pagination.prev') }}
        </a>
      </li>

      <template
        v-for="page in pages"
        :key="page"
      >
        <li
          v-if="page !== null"
          class="page-item"
          :class="currentPage === page ? 'active' : ''"
        >
          <a
            class="page-link"
            @click="goToPage(page)"
            >{{ page }}</a
          >
        </li>

        <li
          v-else
          class="page-item"
        >
          ...
        </li>
      </template>

      <a
        class="page-link"
        :class="currentPage === totalPages ? 'disabled' : ''"
        @click="goToNextPage()"
      >
        {{ $t('pagination.next') }}

        <x-icon
          icon="icon-chevron-right"
          class="icon"
          :size="14"
        ></x-icon>
      </a>
    </ul>
  </div>
</template>

<script setup lang="ts">
const currentPage = defineModel<number>({ required: true });

const { onPage, totalCount, hasLabel } = defineProps<{
  onPage: number;
  totalCount: number;
  hasLabel: boolean;
}>();

/**
 * Вычисляет числа, находящиеся в промежутке from и to с заданным шагом
 * @param from начала промежутка
 * @param to конец промежутка
 * @param step шаг
 * @returns массив чисел в промежутке
 */
const range = (from: number, to: number, step = 1): number[] => {
  let i = from;
  const range: number[] = [];

  while (i <= to) {
    range.push(i);
    i += step;
  }

  return range;
};

/** Страницы пагинации */
const pages = ref<(number | null)[]>([]);

/** Общее количество страниц */
const totalPages = computed(() => Math.ceil(totalCount / onPage));

/** Номер первой записи, отображаемой на текущей странице */
const firstVisibleRow = computed(() => (currentPage.value - 1) * onPage + 1);

/** Номер последней записи, отображаемой на текущей странице */
const lastVisibleRow = computed(() => Math.min(currentPage.value * onPage, totalCount));

/** Актуализирует список страниц для пагинации */
const updatePageNumbers = () => {
  const pageNeighbours = 1;
  const totalNumbers = pageNeighbours + 3;
  const totalBlocks = totalNumbers + 2;

  if (totalPages.value <= totalBlocks) {
    pages.value = range(1, totalPages.value);
    return;
  }

  let newPages: (number | null)[] = [];

  const leftBound = currentPage.value - pageNeighbours;
  const rightBound = currentPage.value + pageNeighbours;
  const beforeLastPage = totalPages.value - 1;

  const startPage = leftBound > 2 ? leftBound : 2;
  const endPage = rightBound < beforeLastPage ? rightBound : beforeLastPage;

  newPages = range(startPage, endPage);

  const pagesCount = newPages.length;
  const singleSpillOffset = totalNumbers - pagesCount - 1;

  const leftSpill = startPage > 2;
  const rightSpill = endPage < beforeLastPage;

  if (leftSpill && !rightSpill) {
    const extraPages = range(startPage - singleSpillOffset, startPage - 1);
    newPages = [null, ...extraPages, ...newPages];
  } else if (!leftSpill && rightSpill) {
    const extraPages = range(endPage + 1, endPage + singleSpillOffset);
    newPages = [...newPages, ...extraPages, null];
  } else if (leftSpill && rightSpill) {
    newPages = [null, ...newPages, null];
  }

  pages.value = [1, ...newPages, totalPages.value];
};

watch(currentPage, () => updatePageNumbers(), { immediate: true });

/**
 * Осуществляет переход на определенную страницу
 * @param page станица
 */
function goToPage(page: number): void {
  if (page > totalPages.value) page = totalPages.value;
  if (page <= 0) page = 1;

  currentPage.value = page;
}

/** Осуществляет переход на предыдущую страницу */
function goToPrevPage(): void {
  goToPage(currentPage.value - 1);
}

/** Осуществляет переход на следующую страницу */
function goToNextPage(): void {
  goToPage(currentPage.value + 1);
}
</script>

<style lang="scss" scoped>
.pagination-container {
  align-items: center;
  display: flex;
  flex-wrap: nowrap;
  justify-content: space-between;
  text-align: center;
  width: 100%;
}

@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
  }
}
</style>
