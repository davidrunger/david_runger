import actionCableConsumer from '@/channels/consumer';

actionCableConsumer.subscriptions.create(
  {
    channel: 'CheckInsChannel',
  },
  {
    received(data) {
      if (data.command === 'redirect') {
        window.location.assign(data.location);
      }
    },
  },
);
