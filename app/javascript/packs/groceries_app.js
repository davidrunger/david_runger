import { renderApp } from 'shared/customized_vue';
import Groceries from 'groceries/groceries.vue';
import { groceryVuexStoreFactory } from 'groceries/store';

renderApp(Groceries, { store: groceryVuexStoreFactory(window.davidrunger.bootstrap) });
