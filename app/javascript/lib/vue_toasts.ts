import { POSITION, useToast } from 'vue-toastification';

import 'css/vue_toastification_with_overrides.scss';

const DEFAULT_VUE_TOASTIFICATION_OPTIONS = Object.freeze({
  position: POSITION.TOP_RIGHT,
});

type ComponentOptions = {
  component: object;
  props?: object;
};

type VueToastificationOptions = {
  icon?: boolean;
  position?: POSITION;
};

export function vueToast(
  messageOrComponentOptions: string | ComponentOptions,
  options?: VueToastificationOptions,
) {
  const toast = useToast();

  const vueToastificationOptions = Object.assign(
    {},
    DEFAULT_VUE_TOASTIFICATION_OPTIONS,
    options || {},
  );

  toast(messageOrComponentOptions, vueToastificationOptions);
}
