import { addNewParticipant } from './addNewParticipant';

test('renders a participant name as text', () => {
  document.body.innerHTML = '<ol id="quiz_participations"></ol>';
  const participantName =
    'Tester<img src=x onerror="document.body.dataset.compromised = true">';

  addNewParticipant(participantName);

  const newListItem = document.querySelector('#quiz_participations li');
  expect(newListItem?.textContent).toEqual(participantName);
  expect(newListItem?.children).toHaveLength(0);
  expect(document.body.dataset.compromised).toBeUndefined();
});
