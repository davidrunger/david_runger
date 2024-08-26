import type { Intersection, UserSerializerWithEmojiBoosts } from '@/types';
import { EmojiPickerIndexBootstrap } from '@/types/bootstrap/EmojiPickerIndexBootstrap';

export type Bootstrap = Intersection<
  {
    current_user?: UserSerializerWithEmojiBoosts;
  },
  EmojiPickerIndexBootstrap
>;
