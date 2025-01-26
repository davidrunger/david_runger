import { Factory } from 'fishery';

import { Log } from '@/logs/types';
import { userFactory } from '@/test/factories/userFactory';

export const logFactory = Factory.define<Log>(({ sequence }) => ({
  data_label: 'Dream content',
  data_type: 'text',
  description: null,
  id: sequence,
  name: 'Dream Journal',
  slug: 'dream-journal',
  user: userFactory.build(),
}));
