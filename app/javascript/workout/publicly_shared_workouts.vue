<template lang='pug'>
div.my2
  h2.h2 Others' workouts
  div(v-if='workouts === null') Loading...
  div(v-else-if='workouts.length === 0') None
  div(v-else)
    workouts-table(:workouts='workouts')
</template>

<script>
import WorkoutsTable from 'workout/workouts_table.vue';

export default {
  components: {
    WorkoutsTable,
  },

  created() {
    this.$http.get(Routes.api_workouts_path({ excluding_user: this.bootstrap.current_user.id })).
      then(({ data }) => {
        this.workouts = data;
      });
  },

  data() {
    return {
      workouts: null,
    };
  },
};
</script>
