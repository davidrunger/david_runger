import { faker } from '@faker-js/faker';
import { Factory } from 'fishery';

import { UserSerializerBasic } from '@/types';

export const userFactory = Factory.define<UserSerializerBasic>(
  ({ sequence }) => ({
    id: sequence,
    email: faker.internet.email(),
  }),
);
