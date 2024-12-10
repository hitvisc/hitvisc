<template>
  <div
    v-if="isVisible"
    class="app-modal__wrapper modal modal-blur"
  >
    <div class="modal-dialog modal-dialog-scrollable">
      <div :style="{ width }">
        <div class="app-modal__main modal-content">
          <!--          <app-loading vIf="loading" :size="36"></app-loading>-->

          <button
            type="button"
            class="btn-close"
            aria-label="Close"
            @click="hide()"
          ></button>

          <div class="modal-header">
            <h5 class="modal-title">{{ title }}</h5>
          </div>

          <div class="modal-body">
            <slot />
          </div>

          <div
            v-if="hasFooter"
            class="modal-footer"
          >
            <button
              type="button"
              class="btn me-auto"
              @click="hide()"
            >
              {{ cancelBtnText }}
            </button>

            <button
              type="button"
              class="btn btn-primary"
              :class="{
                disabled: disabledSubmitBtn,
              }"
              @click="emit('submit')"
            >
              {{ submitBtnText }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
const isVisible = defineModel<boolean>();

const props = withDefaults(
  defineProps<{
    title: string;
    cancelBtnText?: string;
    submitBtnText?: string;
    width?: string;
    disabledSubmitBtn?: boolean;
    hasFooter?: boolean;
  }>(),
  {
    cancelBtnText: 'Cancel',
    submitBtnText: 'Submit',
    width: undefined,
    disabledSubmitBtn: false,
    hasFooter: true,
  },
);

const { title, cancelBtnText, submitBtnText, width, disabledSubmitBtn, hasFooter } = toRefs(props);

const emit = defineEmits<{
  close: [];
  submit: [];
}>();

function hide() {
  isVisible.value = false;
  emit('close');
}
</script>

<style lang="scss" scoped>
.app-modal {
  background: rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(4px);
  bottom: 0;
  display: flex;
  height: 100vh;
  left: 0;
  overflow-y: hidden;
  position: fixed;
  right: 0;
  top: 0;
  width: 100%;
  z-index: 1040;

  &__wrapper {
    display: flex;
    justify-content: center;
    width: 100%;
  }
}

.btn-close {
  height: 20px;
  opacity: 1;
  position: absolute;
  right: 25px;
  top: 25px;
  width: 20px;
}
</style>
