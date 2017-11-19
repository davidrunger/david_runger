<template lang='pug'>
  transition(name='modal')
    div.modal-mask.fixed.flex.items-center.justify-center.col-12.top-0.left-0.vh-100.z1
      div.modal-container.p3.bg-white.rounded
        slot
</template>

<style lang='scss' scoped>
.modal-mask {
  background-color: rgba(0, 0, 0, 0.5);
  transition: opacity 0.3s ease;
}

.modal-container {
  width: 300px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
  transition: all 0.3s ease;
  font-family: Helvetica, Arial, sans-serif;
}

.modal-enter {
  opacity: 0;
}

.modal-leave-active {
  opacity: 0;
}

.modal-enter .modal-container,
.modal-leave-active .modal-container {
  transform: scale(1.1);
}
</style>
