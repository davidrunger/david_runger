import 'element-plus/lib/theme-chalk/base.css';
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
  ElSubmenu,
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
  app.use(ElIcon);
  app.use(ElInput);
  app.use(ElMenu);
  app.use(ElMenuItem);
  app.use(ElOption);
  app.use(ElSelect);
  app.use(ElSubmenu);
  app.use(ElSwitch);
  app.use(ElTag);
}
