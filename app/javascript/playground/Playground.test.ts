import { render, screen } from '@testing-library/vue';

import Playground from './Playground.vue';

test('displays welcome text', () => {
  render(Playground);

  screen.getByText('Welcome to Vue, David!');
});
