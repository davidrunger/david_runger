import { assert } from '@/lib/helpers';

export function addNewParticipant(newParticipantName: string) {
  const quizParticipationsList = assert(
    document.getElementById('quiz_participations'),
  );

  const existingListing = Array.from(
    quizParticipationsList.querySelectorAll('li'),
  ).find((el) => el.innerText === newParticipantName);
  if (!existingListing) {
    const newListItem = document.createElement('li');
    newListItem.textContent = newParticipantName;
    quizParticipationsList.appendChild(newListItem);
  }
}
