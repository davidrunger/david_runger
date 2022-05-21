import {
  ElButton,
  ElCard,
  ElCheckbox,
  ElCollapse,
  ElCollapseItem,
  ElDatePicker,
  ElIcon,
  ElInput,
  ElMenu,
  ElMenuItem,
  ElOption,
  ElSelect,
  ElSubMenu,
  ElSwitch,
  ElTag,
} from 'element-plus';
import * as ElementPlusIconsVue from '@element-plus/icons-vue';

export function useElementPlus(app) {
  app.use(ElButton);
  app.use(ElCard);
  app.use(ElCheckbox);
  app.use(ElCollapse);
  app.use(ElCollapseItem);
  app.use(ElDatePicker);
  app.use(ElIcon);
  app.use(ElInput);
  app.use(ElMenu);
  app.use(ElMenuItem);
  app.use(ElOption);
  app.use(ElSelect);
  app.use(ElSubMenu);
  app.use(ElSwitch);
  app.use(ElTag);
  // eslint-disable-next-line no-restricted-syntax
  for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component);
  }
}
