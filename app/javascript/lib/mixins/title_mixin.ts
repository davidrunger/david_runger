import { ComponentPublicInstance } from 'vue';

function getTitle(vm: ComponentPublicInstance) {
  const { title } = vm.$options;
  if (title) {
    return (typeof title === 'function') ?
      title.call(vm) :
      title;
  } else {
    return null;
  }
}

const titleMixin = {
  created() {
    const title = getTitle(this as unknown as ComponentPublicInstance);
    if (title) {
      document.title = title;
    }
  },
};

export default titleMixin;
