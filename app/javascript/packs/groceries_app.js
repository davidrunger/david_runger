import { renderApp } from 'shared/customized_vue';
import Groceries from 'groceries/groceries.vue';
import store from 'groceries/store';

renderApp(Groceries, { store });
