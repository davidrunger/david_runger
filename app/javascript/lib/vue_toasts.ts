import { POSITION, TYPE, useToast } from 'vue-toastification';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import type { UniversalBootstrapData } from '@/lib/types';

import 'css/vue_toastification_with_overrides.css';

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
  type?: TYPE;
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

export function renderBootstrappedToasts() {
  const bootstrap = untypedBootstrap as UniversalBootstrapData;

  const alertToastMessages = bootstrap.alert_toast_messages;
  const noticeToastMessages = bootstrap.notice_toast_messages;

  if (alertToastMessages?.length) {
    for (const message of alertToastMessages) {
      vueToast(message, { position: POSITION.TOP_CENTER, type: TYPE.ERROR });
    }
  }

  if (noticeToastMessages?.length) {
    for (const message of noticeToastMessages) {
      vueToast(message, { position: POSITION.TOP_CENTER });
    }
  }
}
