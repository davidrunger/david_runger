import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import type { Bootstrap } from '@/logs/types';

export const bootstrap = untypedBootstrap as Bootstrap;
