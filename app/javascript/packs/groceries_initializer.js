import { renderApp } from 'vendor/customized_vue';
import Groceries from 'groceries/groceries.vue';
import { groceryVuexStoreFactory } from 'groceries/store';
import 'shared/common';

renderApp(Groceries, { store: groceryVuexStoreFactory(window.davidrunger.bootstrap) });
