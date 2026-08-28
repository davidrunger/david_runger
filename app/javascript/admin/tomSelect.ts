import TomSelect from 'tom-select';

import 'tom-select/dist/css/tom-select.default.css';

function initializeActiveAdminTomSelect() {
  const selectsToInitialize = document.querySelectorAll(
    'select[id^="q_"]:not(.tomselected)',
  );

  selectsToInitialize.forEach((selectEl) => {
    if (selectEl instanceof HTMLSelectElement) {
      new TomSelect(selectEl, {
        create: false,
        sortField: [
          {
            field: 'text',
            direction: 'asc',
          },
        ],
      });
    }
  });
}

document.addEventListener('DOMContentLoaded', () => {
  initializeActiveAdminTomSelect();
});
