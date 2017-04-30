<template>
  <div id="app">
    <h1>{{ template.name }}</h1>
    <h2>Template</h2>
    <textarea v-model='template.body'></textarea>
    <div v-if='saving'>saving...</div>
    <div v-if='saved'>saved.</div>
    <hr/>
    <h2>Variables</h2>
    <div v-if='variables.length'>
      <div v-for='variable in variables'>
        <label>{{ variable.name }}</label>
        <input type="text" v-model='variable.value'>
      </div>
    </div>
    <hr/>
    <h2>Rendered</h2>
      <p>
        {{rendered()}}
      </p>
    </div>
  </div>
</template>

<script>
import { debounce, find } from 'lodash';

export default {
  beforeMount() {
    this.updateVariables();
  },

  data() {
    return Object.assign({},
      window.davidrunger.bootstrap,
      {
        saved: false,
        saving: false,
        variables: [
          { name: 'room', value: 'Arguello' }
        ],
      }
    );
  },

  methods: {
    rendered() {
      let rendered = this.template.body;
      this.variables.forEach(variable => {
        if (variable.value) {
          const regex = new RegExp(`{{${variable.name}}}`, 'g');
          rendered = rendered.replace(regex, variable.value);
        }
      });
      return rendered;
    },

    updateServer: debounce(
      function () {
        this.$http.patch(`/api/templates/${this.template.id}`, {
          template: {
            body: this.template.body,
          },
        })
        .then(() => {
          this.saving = false;
          this.saved = true;
        });
      },
      1000
    ),

    updateVariables() {
      const variableRegex = /{{([^{}]*)}}/g;
      const newVariables = [];
      let match = variableRegex.exec(this.template.body);
      while (match) {
        const name = match[1];
        const existingVariable = find(this.variables, variable => variable.name === name)
        newVariables.push({
          name: name,
          value: existingVariable ? existingVariable.value : '',
        });
        match = variableRegex.exec(this.template.body);
      }
      this.variables = newVariables;
    },
  },

  watch: {
    'template.body': function () {
      this.saving = true;
      this.saved = false;
      this.updateServer();
      this.updateVariables();
    },
  },
}
</script>

<style scoped>
textarea {
  width: 100%;
  height: 100px;
}
</style>
