import { faker } from '@faker-js/faker';
import { Factory } from 'fishery';

import { LogEntry } from '@/types';

export const logEntryFactory = Factory.define<LogEntry>(({ sequence }) => ({
  id: sequence,
  log_id: 1,
  note: null,
  created_at: faker.date.past().toISOString(),
  data: faker.commerce.productDescription(),
}));
