import { Turbo } from '@hotwired/turbo-rails';
import Rails from '@rails/ujs';

import actionCableConsumer from '@/channels/consumer';
import { loadAsyncPartials } from '@/lib/async_partial';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { assert } from '@/lib/helpers';
import type { Intersection, Quiz, UserSerializerBasic } from '@/types';
import { QuizShowBootstrap } from '@/types/bootstrap/QuizShowBootstrap';

// https://github.com/hotwired/turbo-rails/issues/135#issuecomment-814413558
Rails.delegate(
  document,
  Rails.linkDisableSelector,
  'turbo:before-cache',
  Rails.enableElement,
);
Rails.delegate(
  document,
  Rails.buttonDisableSelector,
  'turbo:before-cache',
  Rails.enableElement,
);
Rails.delegate(
  document,
  Rails.buttonDisableSelector,
  'turbo:submit-end',
  Rails.enableElement,
);
Rails.delegate(
  document,
  Rails.formSubmitSelector,
  'turbo:submit-start',
  Rails.disableElement,
);
Rails.delegate(
  document,
  Rails.formSubmitSelector,
  'turbo:submit-end',
  Rails.enableElement,
);
Rails.delegate(
  document,
  Rails.formSubmitSelector,
  'turbo:before-cache',
  Rails.enableElement,
);

document.documentElement.addEventListener('turbo:load', loadAsyncPartials);

type Bootstrap = Intersection<
  {
    current_user: UserSerializerBasic;
    quiz: Quiz;
  },
  QuizShowBootstrap
>;

interface QuizzesCableData {
  command: string;
  new_answerer_name?: string;
  new_participant_name?: string;
}

const bootstrap = untypedBootstrap as Bootstrap;

actionCableConsumer.subscriptions.create(
  {
    channel: 'QuizzesChannel',
    quiz_id: bootstrap.quiz.hashid,
  },
  {
    received(data: QuizzesCableData) {
      if (!data) return;

      if (
        data.command === 'refresh' &&
        // The owner initiated the action prompting this refresh (via closing question or advancing
        // to next question), and his refresh will be handled via the response to that request.
        bootstrap.current_user.id !== bootstrap.quiz.owner_id
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

function getDangerouslyById(id: string) {
  const el = assert(document.getElementById(id));

  if (el === null)
    throw new Error(`Element with id '${id}' could not be found!`);

  return el;
}

function refresh() {
  Turbo.cache.clear();
  Turbo.visit(window.location.pathname, { action: 'replace' });
}

function addNewAnswerer(newAnswererName: string) {
  const el = document.getElementById('quiz_question_answer_selections');

  if (el) {
    const matchedLi = assert(
      Array.from(el.querySelectorAll('li')).find(
        (li) => li.innerText === newAnswererName,
      ),
    );

    matchedLi.classList.add('font-bold');
  }
}

function addNewParticipant(newParticipantName: string) {
  const quizParticipationsList = getDangerouslyById('quiz_participations');

  const existingListing = Array.from(
    quizParticipationsList.querySelectorAll('li'),
  ).find((el) => el.innerText === newParticipantName);
  if (!existingListing) {
    const newListItem = document.createElement('li');
    newListItem.innerHTML = newParticipantName;
    quizParticipationsList.appendChild(newListItem);
  }
}
