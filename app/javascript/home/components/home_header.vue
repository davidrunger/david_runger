<template lang='pug'>
header#header.flex-grow-1.flex.justify-between.bg-black.col-12.relative
  .font-size-2.js-link.js-scroll-top.ml3
    a#logo.monospace.font-blue-light.opacity-animated(
      href='#home'
      :class='{ "opacity-0": homeIsVisible }'
    )
      | David Runger
  nav#nav.sans-serif.flex.justify-around.absolute.mr3
    NavLink(section='about')
    NavLink(section='skills')
    NavLink(section='projects')
    NavLink(section='resume')
    NavLink(section='links' link-text='Contact/Links')
  .toggleable-menu
    .line-container(:class='{ "menu-open": homeStore.menuOpen }')
      .line
      .line
      .line
    .clearfix.header-height-spacer
    input.menu-toggle(
      type='checkbox'
      ref='menu-toggle-checkbox'
      @click='homeStore.menuOpen = !homeStore.menuOpen'
    )
    .mobile-nav.dvh-100
      ul
        li(@click='collapseMobileMenu')
          NavLink(section='about')
        li(@click='collapseMobileMenu')
          NavLink(section='skills')
        li(@click='collapseMobileMenu')
          NavLink(section='projects')
        li(@click='collapseMobileMenu')
          NavLink(section='resume')
        li(@click='collapseMobileMenu')
          NavLink(section='contact')
</template>

<script>
import { mapState } from 'pinia';
import { useHomeStore } from '@/home/store';
import NavLink from './nav_link.vue';

export default {
  components: {
    NavLink,
  },

  computed: {
    ...mapState(useHomeStore, [
      'homeIsVisible',
    ]),
  },

  data() {
    return {
      homeStore: useHomeStore(),
    };
  },

  methods: {
    collapseMobileMenu() {
      this.homeStore.menuOpen = false;
      this.$refs['menu-toggle-checkbox'].checked = false;
    },
  },
};
</script>

<style lang='scss' scoped>
@import "css/variables";

#header {
  position: fixed;
  // performance hint to create a new compositor layer, so we don't re-paint on scroll
  will-change: transform;
  top: 0;
  z-index: 1;
  height: $header-height;
  line-height: $header-height;

  #nav {
    width: 500px;
    right: 0;

    @media screen and (max-width: $small-screen-breakpoint) {
      display: none;
    }
  }
}

.toggleable-menu {
  display: none;

  @media screen and (max-width: $small-screen-breakpoint) {
    display: block;
  }
}

.header-height-spacer {
  height: $header-height;
}

.line-container {
  float: right;
  margin-top: 11px;
  margin-right: 20px;
  z-index: 10;
  position: relative;

  .line {
    width: 30px;
    height: 2px;
    margin: 7px 0;
    background-color: white;
    transition: transform 0.3s linear, width 0.3s linear;
  }

  &.menu-open {
    .line:nth-child(1),
    .line:nth-child(3) {
      width: 35px;
    }

    .line:nth-child(1) {
      transform: translateY(7px) rotate(45deg);
    }

    .line:nth-child(2) {
      transform: translateX(100px);
    }

    .line:nth-child(3) {
      transform: translateY(-10px) rotate(-45deg);
    }
  }
}

input.menu-toggle[type="checkbox"] {
  position: absolute;
  top: 8px;
  right: 12px;
  width: 40px;
  height: 38px;
  cursor: pointer;
  opacity: 0;
  z-index: 11;
}

.mobile-nav {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  padding-top: 80px;
  text-align: center;
  background: #111;
  transition: transform 0.3s;
  transform: translate(0, -100%);

  ul {
    list-style: none;
    padding: 0;
  }

  li a {
    color: #b5b6be;
    display: block;
    padding: 25px 20px;
    font-size: 25px;

    &:hover {
      color: white;
    }
  }
}

input:checked + .mobile-nav {
  transform: translate(0, 0);
}
</style>
