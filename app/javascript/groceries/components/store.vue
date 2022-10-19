<template lang="pug">
div.mt1.mb2.ml3.mr2
  h2.h2.store-name.bold.my2
    input(
      v-if='editingName'
      type='text'
      v-model='store.name'
      @blur='stopEditingAndUpdateStoreName()'
      @keydown.enter='stopEditingAndUpdateStoreName()'
      ref='store-name-input'
    )
    span(v-if='!editingName') {{ store.name }}
    a.edit-store.js-link.gray.ml1(@click='editStoreName')
      edit-icon(size='27')
    span(v-if='store.own_store')
      el-button.ml1(v-if='store.private' size='small' @click='togglePrivacy') Make public
      el-button.ml1(v-else size='small' @click='togglePrivacy') Make private
    span.spinner--circle.ml1(v-if='debouncingOrWaitingOnNetwork')
  div.mb2
    el-button(id="show-modal" @click='initializeTripCheckinModal()').
      Check in shopping trip
    el-button.copy-to-clipboard Copy to clipboard
    span(v-if='wasCopiedRecently') Copied!

  div.mb1
    h3.h3 Notes
    el-input(
      v-if='editingNotes'
      type='textarea'
      placeholder='Member phone number: 619-867-5309'
      v-model='store.notes'
      @blur='stopEditingAndUpdateStoreNotes()'
      ref='store-notes-input'
    )
    p.pre-wrap(v-else)
      | {{store.notes || 'No notes yet'}}
      a.edit-store.js-link.gray.ml1(v-if='store.own_store' @click='editStoreNotes')
        edit-icon(size='18')

  form.flex(v-if='store.own_store' @submit.prevent='postNewItem')
    .float-left
      el-input.item-name-input(
        placeholder='Add an item'
        type='text'
        v-model='newItemName'
        name='newItemName'
      )
    .ml1
      el-button.flex-0.button.button-outline(
        native-type='submit'
        :disabled='v$.$invalid'
      ) Add

  .items-list.mt0.mb0(v-auto-animate)
    Item(
      v-for='item in sortedItems'
      :item="item"
      :key="item.id"
      :ownStore='store.own_store'
    )

  Modal(name='check-in-shopping-trip' width='85%' maxWidth='400px')
    slot
      h3.bold.mb2.
        What did you get?
      ul
        li.flex.items-center.mb1(v-for='(item, index) in neededItems' :key='item.id')
          input(
            type='checkbox'
            v-model='itemsToZero'
            :value='item'
            :id='`trip-checkin-item-${item.id}`'
          )
          label.ml1(:for='`trip-checkin-item-${item.id}`') {{item.name}}
      div.flex.justify-around.mt2
        el-button(
          @click='handleTripCheckinModalSubmit'
          type='primary'
          plain
        ) Set checked items to 0 needed
        el-button(
          @click="$store.commit('hideModal', { modalName: 'check-in-shopping-trip' })"
          type='primary'
          link
        ) Cancel
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import { sortBy } from 'lodash-es';
import ClipboardJS from 'clipboard';
import { EditIcon } from 'vue-tabler-icons';
import { required } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';

import Item from './item.vue';

export default {
  components: {
    EditIcon,
    Item,
  },

  computed: {
    ...mapGetters([
      'debouncingOrWaitingOnNetwork',
    ]),

    ...mapState([
      'current_user',
    ]),

    neededItems() {
      return this.sortItems(this.store.items.filter(item => item.needed > 0));
    },

    sortedItems() {
      return this.sortItems(this.store.items);
    },
  },

  data() {
    return {
      editingName: false,
      editingNotes: false,
      itemsToZero: [],
      newItemName: '',
      wasCopiedRecently: false,
    };
  },

  mounted() {
    const clipboard = new ClipboardJS('.copy-to-clipboard', {
      text: () => this.neededItems.map(item => `${item.name} (${item.needed})`).join('\n'),
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => { this.wasCopiedRecently = false; }, 3000);
    });
  },

  methods: {
    editStoreName() {
      this.editingName = true;
      // wait a tick for input to render, then focus it
      setTimeout(this.focusStoreNameInput);
    },

    editStoreNotes() {
      this.editingNotes = true;
      // wait a tick for input to render, then focus it
      setTimeout(this.focusStoreNotesInput);
    },

    focusStoreNameInput(callsAlready = 0) {
      if (!this.editingName) return;

      const storeNameInput = this.$refs['store-name-input'];
      if (storeNameInput) {
        storeNameInput.focus();
      } else if (callsAlready < 20) {
        // the storeNameInput hasn't had time to render yet; retry later
        setTimeout(() => { this.focusStoreNameInput(callsAlready + 1); }, 50);
      }
    },

    focusStoreNotesInput(callsAlready = 0) {
      if (!this.editingNotes) return;

      const storeNotesInput = this.$refs['store-notes-input'];
      if (storeNotesInput) {
        storeNotesInput.focus();
      } else if (callsAlready < 20) {
        // the storeNotesInput hasn't had time to render yet; retry later
        setTimeout(() => { this.focusStoreNotesInput(callsAlready + 1); }, 50);
      }
    },

    handleTripCheckinModalSubmit() {
      this.$store.dispatch('zeroItems', { items: this.itemsToZero.slice() });
      this.itemsToZero = [];
      this.$store.commit('hideModal', { modalName: 'check-in-shopping-trip' });
    },

    initializeTripCheckinModal() {
      this.$store.commit('showModal', { modalName: 'check-in-shopping-trip' });
    },

    postNewItem() {
      this.$store.commit('incrementPendingRequests');
      this.$store.dispatch('createItem', {
        store: this.store,
        itemAttributes: {
          name: this.newItemName,
        },
      });
      this.newItemName = '';
    },

    sortItems(items) {
      return sortBy(items, item => item.name.toLowerCase());
    },

    stopEditingAndUpdateStoreName() {
      this.editingName = false;
      this.$store.dispatch('updateStore', {
        store: this.store,
        attributes: {
          name: this.store.name,
        },
      });
    },

    stopEditingAndUpdateStoreNotes() {
      this.editingNotes = false;
      this.$store.dispatch('updateStore', {
        store: this.store,
        attributes: {
          notes: this.store.notes,
        },
      });
    },

    togglePrivacy() {
      this.$store.dispatch('updateStore', {
        store: this.store,
        attributes: {
          private: !this.store.private,
        },
      });
    },
  },

  props: {
    store: {
      type: Object,
      required: true,
    },
  },

  setup: () => ({ v$: useVuelidate() }),

  validations() {
    return {
      newItemName: { required },
    };
  },
};
</script>

<style lang='scss' scoped>
.item-name-input {
  max-width: 230px;
}

.spinner--circle {
  height: 14px;
  width: 14px;
}

.edit-store {
  &:hover {
    color: black;
  }
}
</style>
