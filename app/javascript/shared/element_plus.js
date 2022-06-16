import {
  ElButton,
  ElCard,
  ElCheckbox,
  ElCollapse,
  ElCollapseItem,
  ElDatePicker,
  ElInput,
  ElMenu,
  ElMenuItem,
  ElOption,
  ElSelect,
  ElSubMenu,
  ElSwitch,
  ElTag,
} from 'element-plus';

export function useElementPlus(app) {
  app.use(ElButton);
  app.use(ElCard);
  app.use(ElCheckbox);
  app.use(ElCollapse);
  app.use(ElCollapseItem);
  app.use(ElDatePicker);
  app.use(ElInput);
  app.use(ElMenu);
  app.use(ElMenuItem);
  app.use(ElOption);
  app.use(ElSelect);
  app.use(ElSubMenu);
  app.use(ElSwitch);
  app.use(ElTag);
}
