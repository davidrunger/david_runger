import 'spec_helper';
import { initialState, mutations } from 'groceries/store';

describe('Grocery Vuex store', function () { // eslint-disable-line func-names
  const suite = this;
  suite.timeout(120000); // make timeout 2 minutes to allow time to play around in `debugger`

  const item = { id: 48, name: 'bananas', needed: 0 };
  const groceryStore = { id: 1, name: 'Costco', items: [item] };
  const bootstrap = { stores: [groceryStore] };

  let state;

  beforeEach(() => {
    state = initialState(bootstrap);
  });

  describe('#deleteItem', () => {
    it("removes the item from the currentStore's items", () => {
      expect(state.stores[0].items).toContain(item);

      mutations.deleteItem(state, {
        item,
        store: groceryStore,
      });

      expect(state.stores[0].items).not.toContain(item);
    });
  });

  describe('#deleteStore', () => {
    it("removes the deleted store from the state's stores", () => {
      expect(state.stores).toContain(groceryStore);

      mutations.deleteStore(state, { store: groceryStore });

      expect(state.stores).not.toContain(groceryStore);
    });
  });
});
