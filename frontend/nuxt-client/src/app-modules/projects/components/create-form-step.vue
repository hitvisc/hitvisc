<template>
  <div class="accordion-item">
    <h2 class="accordion-header">
      <button
        class="accordion-button"
        :class="{
          collapsed: !isCurrentStep,
        }"
        type="button"
        :aria-expanded="isCurrentStep"
        @click="emit('collapse')"
      >
        {{ $t(`projects.creator.${id}`) }}
        <x-icon
          v-if="done"
          icon="icon-circle-check"
          :size="16"
          class="mx-2"
          style="color: var(--tblr-green)"
        />
      </button>
    </h2>
    <div
      :id="id"
      class="accordion-collapse collapse"
      :class="{
        show: isCurrentStep,
      }"
    >
      <div class="accordion-body pt-0">
        <slot />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
const props = defineProps<{
  step: number;
  currentStep: number;
  done: boolean;
}>();

const { step, currentStep, done } = toRefs(props);

const emit = defineEmits<{
  collapse: [];
}>();

const id = `step${step.value}`;

const isCurrentStep = computed(() => step.value === currentStep.value);
</script>
