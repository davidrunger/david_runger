import actionCableConsumer from 'channels/consumer';
import { Turbo } from '@hotwired/turbo-rails';

actionCableConsumer.subscriptions.create(
  {
    channel: 'QuizzesChannel',
    quiz_id: window.davidrunger.bootstrap.quiz.hashid,
  },
  {
    received(data) {
      if (data && data.command === 'refresh') {
        Turbo.visit(window.location.pathname, { action: 'replace' });
      }
    },
  },
);
