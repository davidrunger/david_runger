import actionCableConsumer from '@/channels/consumer';

actionCableConsumer.subscriptions.create(
  {
    channel: 'CheckInsChannel',
    marriage_id: window.davidrunger.bootstrap.marriage.id,
  },
  {
    received(data) {
      if (data.command === 'redirect') {
        window.location.assign(data.location);
      }
    },
  },
);
