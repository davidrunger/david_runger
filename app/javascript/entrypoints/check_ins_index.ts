import actionCableConsumer from '@/channels/consumer';

actionCableConsumer.subscriptions.create(
  {
    channel: 'CheckInsChannel',
  },
  {
    received(data: { command?: string; location?: string }) {
      if (data.command === 'redirect' && data.location) {
        window.location.assign(data.location);
      }
    },
  },
);
