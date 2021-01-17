import actionCableConsumer from 'channels/consumer';
import { Turbo } from '@hotwired/turbo-rails';

actionCableConsumer.subscriptions.create(
  {
    channel: 'QuizzesChannel',
    quiz_id: window.davidrunger.bootstrap.quiz.hashid,
  },
  {
    received(data) {
      if (!data) return;

      if (data.command === 'refresh') {
        Turbo.visit(window.location.pathname, { action: 'replace' });
      } else if (data.new_answerer_name) {
        [...document.getElementById('quiz_question_answer_selections').querySelectorAll('li')].
          find(el => el.innerText === data.new_answerer_name).
          classList.add('bold');
      }
    },
  },
);
