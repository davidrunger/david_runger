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

import 'element-plus/lib/theme-chalk/base.css';
import 'element-plus/lib/theme-chalk/el-button.css';
import 'element-plus/lib/theme-chalk/el-card.css';
import 'element-plus/lib/theme-chalk/el-checkbox.css';
import 'element-plus/lib/theme-chalk/el-date-picker.css';
import 'element-plus/lib/theme-chalk/el-dropdown-item.css';
import 'element-plus/lib/theme-chalk/el-icon.css';
import 'element-plus/lib/theme-chalk/el-input.css';
import 'element-plus/lib/theme-chalk/el-menu.css';
import 'element-plus/lib/theme-chalk/el-menu-item.css';
import 'element-plus/lib/theme-chalk/el-option.css';
import 'element-plus/lib/theme-chalk/el-select.css';
import 'element-plus/lib/theme-chalk/el-submenu.css';
import 'element-plus/lib/theme-chalk/el-switch.css';
import 'element-plus/lib/theme-chalk/el-tag.css';

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
