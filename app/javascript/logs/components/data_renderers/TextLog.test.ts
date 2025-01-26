import { faker } from '@faker-js/faker';
import { createTestingPinia } from '@pinia/testing';
import { render, screen } from '@testing-library/vue';
import { ElButton } from 'element-plus';

import { Log } from '@/logs/types';
import { logEntryFactory } from '@/test/factories/logEntryFactory';
import { logFactory } from '@/test/factories/logFactory';

import TextLog from './TextLog.vue';

function renderOptions(specifiedProps: { log: Log }) {
  return {
    global: {
      components: {
        'el-button': ElButton,
      },
      plugins: [createTestingPinia()],
    },
    props: specifiedProps,
  };
}

describe('when the log has log entries', () => {
  test('renders the text of the log entries', () => {
    const oldLogEntry = logEntryFactory.build({
      created_at: faker.date
        .between({
          from: '2020-01-01T00:00:00.000Z',
          to: '2021-01-01T00:00:00.000Z',
        })
        .toISOString(),
    });

    const newLogEntry = logEntryFactory.build({
      created_at: faker.date
        .between({
          from: '2021-01-01T00:00:00.000Z',
          to: '2022-01-01T00:00:00.000Z',
        })
        .toISOString(),
    });

    const log = logFactory.build({
      log_entries: [newLogEntry, oldLogEntry],
    });

    render(TextLog, renderOptions({ log }));

    assert(log.log_entries);

    const oldLogEntryElement = screen.getByText(oldLogEntry.data);
    const newLogEntryElement = screen.getByText(newLogEntry.data);
    expect(
      newLogEntryElement.compareDocumentPosition(oldLogEntryElement),
    ).toEqual(4); // new log entry precedes the old log entry
  });
});
