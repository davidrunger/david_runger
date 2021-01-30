import 'element-plus/lib/theme-chalk/el-card.css';
import { ElCard } from 'element-plus';
import { renderApp } from 'shared/customized_vue';
import Home from 'home/home.vue';

const app = renderApp(Home);
app.use(ElCard);
