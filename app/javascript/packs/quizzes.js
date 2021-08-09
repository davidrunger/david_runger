import Rails from '@rails/ujs';
import { Turbo } from '@hotwired/turbo-rails';

import actionCableConsumer from '@/channels/consumer';
import { loadAsyncPartials } from '@/lib/async_partial';

Rails.start();
// https://github.com/hotwired/turbo-rails/issues/135#issuecomment-814413558
Rails.delegate(document, Rails.linkDisableSelector, 'turbo:before-cache', Rails.enableElement);
Rails.delegate(document, Rails.buttonDisableSelector, 'turbo:before-cache', Rails.enableElement);
Rails.delegate(document, Rails.buttonDisableSelector, 'turbo:submit-end', Rails.enableElement);
Rails.delegate(document, Rails.formSubmitSelector, 'turbo:submit-start', Rails.disableElement);
Rails.delegate(document, Rails.formSubmitSelector, 'turbo:submit-end', Rails.enableElement);
Rails.delegate(document, Rails.formSubmitSelector, 'turbo:before-cache', Rails.enableElement);

document.documentElement.addEventListener('turbo:load', loadAsyncPartials);

actionCableConsumer.subscriptions.create(
  {
    channel: 'QuizzesChannel',
    quiz_id: window.davidrunger.bootstrap.quiz.hashid,
  },
  {
    received(data) {
      if (!data) return;

      if (
        data.command === 'refresh' &&
        // The owner initiated the action prompting this refresh (via closing question or advancing
        // to next question), and his refresh will be handled via the response to that request.
        window.davidrunger.bootstrap.current_user.id !== window.davidrunger.bootstrap.quiz.owner_id
      ) {
        refresh();
      } else if (data.new_answerer_name) {
        addNewAnswerer(data.new_answerer_name);
      } else if (data.new_participant_name) {
        addNewParticipant(data.new_participant_name);
      }
    },
  },
);

function refresh() {
  Turbo.clearCache();
  Turbo.visit(window.location.pathname, { action: 'replace' });
}

function addNewAnswerer(newAnswererName) {
  [...document.getElementById('quiz_question_answer_selections').querySelectorAll('li')].
    find(el => el.innerText === newAnswererName).
    classList.add('bold');
}

function addNewParticipant(newParticipantName) {
  const quizParticipationsList = document.getElementById('quiz_participations');
  const existingListing =
    [...quizParticipationsList.querySelectorAll('li')].
      find(el => el.innerText === newParticipantName);
  if (!existingListing) {
    const newListItem = document.createElement('li');
    newListItem.innerHTML = newParticipantName;
    quizParticipationsList.appendChild(newListItem);
  }
}
