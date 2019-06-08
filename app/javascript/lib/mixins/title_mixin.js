function getTitle(vm) {
  const { title } = vm.$options;
  if (title) {
    return (typeof title === 'function') ?
      title.call(vm) :
      title;
  }
}

const titleMixin = {
  created() {
    const title = getTitle(this);
    if (title) {
      document.title = title;
    }
  },
};

export default titleMixin;
