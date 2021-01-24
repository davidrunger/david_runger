import { renderApp } from 'shared/customized_vue';
import Groceries from 'groceries/groceries.vue';
import storeDefinition from 'groceries/store';

renderApp(Groceries, { storeDefinition });
