import { renderApp } from 'shared/customized_vue';
import { useElementPlus } from 'shared/element_plus';
import Groceries from 'groceries/groceries.vue';
import storeDefinition from 'groceries/store';

const app = renderApp(Groceries, { storeDefinition });
useElementPlus(app);
