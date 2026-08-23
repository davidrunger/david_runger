import type { Bootstrap } from '@/groceries/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';

export const bootstrap = untypedBootstrap as Bootstrap;
