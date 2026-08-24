import { resolveConfig } from 'vite';

describe('vite.config.mjs', () => {
  it('sets the WebSocket client port when the Vite CLI supplies server config', async () => {
    const config = await resolveConfig({ server: {} }, 'serve');

    expect(config.server.ws).toEqual(
      expect.objectContaining({ clientPort: 3036 }),
    );
  });
});
