<template>
  <div id="app">
    <h1>{{ template.name }}</h1>
    <small><a href='/templates'>&lt; All Templates</a></small>
    <h2>Template</h2>
    <textarea v-model='template.body'></textarea>
    <div v-if='saving'>saving...</div>
    <div v-if='saved'>saved.</div>
    <hr/>
    <h2>Fill in the Blanks</h2>
    <div v-if='variables.length'>
      <div v-for='variable in variables'>
        <label>{{ variable.name }}</label>
        <input type="text" v-model='variable.value'>
      </div>
    </div>
    <hr/>
    <h2>Rendered</h2>
    <p class='renderedText'>{{renderedText()}}</p>
    <button class='copy-to-clipboard'>Copy to Clipboard</button>
    <span v-if='wasCopiedRecently'>Copied!</span>
  </div>
</template>

<script>
import { debounce, find, uniqBy } from 'lodash';
import Clipboard from 'clipboard';

export default {
  beforeMount() {
    this.updateVariables();
  },

  mounted() {
    const clipboard = new Clipboard('.copy-to-clipboard', {
      text: () => this.renderedText(),
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => {
        this.wasCopiedRecently = false;
      }, 3000);
    });
  },

  data() {
    return Object.assign({},
      this.bootstrap,
      {
        wasCopiedRecently: false,
        saved: false,
        saving: false,
        variables: [],
      },
    );
  },

  methods: {
    renderedText() {
      let renderedText = this.template.body;
      this.variables.forEach(variable => {
        if (variable.value) {
          const regex = new RegExp(`{${variable.name}}`, 'g');
          renderedText = renderedText.replace(regex, variable.value);
        }
      });
      this.latestRender = renderedText;
      return renderedText;
    },

    updateServer: debounce(
      // we need `function` for correct `this`
      // eslint-disable-next-line func-names
      function () {
        this.$http.patch(`/api/templates/${this.template.id}`, {
          template: {
            body: this.template.body,
          },
        }).then(() => {
          this.saving = false;
          this.saved = true;
        });
      },
      1000,
    ),

    updateVariables() {
      const variableRegex = /{([^{}]*)}/g;
      const newVariables = [];
      let match = variableRegex.exec(this.template.body);
      while (match) {
        const name = match[1];
        const existingVariable = find(this.variables, variable => variable.name === name);
        newVariables.push({
          name,
          value: existingVariable ? existingVariable.value : '',
        });
        match = variableRegex.exec(this.template.body);
      }
      this.variables = uniqBy(newVariables, variable => variable.name);
    },
  },

  watch: {
    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    'template.body': function () {
      this.saving = true;
      this.saved = false;
      this.updateServer();
      this.updateVariables();
    },
  },
};
</script>

<style scoped>
hr {
  margin: 12px 0;
}

h1,
h2 {
  text-align: left;
}

h1 {
  margin-bottom: 0;
}

textarea {
  width: 100%;
  height: 150px;
}

.renderedText {
  white-space: pre-wrap;
}

.copy-to-clipboard {
  font-size: 20px;
}
</style>
