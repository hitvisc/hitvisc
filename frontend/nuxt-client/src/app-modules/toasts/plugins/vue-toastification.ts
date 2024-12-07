import * as vt from 'vue-toastification';
import { type PluginOptions } from 'vue-toastification/src/types';
import 'vue-toastification/dist/index.css';

const options: PluginOptions = {
  // options
};

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.use(vt.default, options);
  return {
    provide: {
      toast: vt,
    },
  };
});
