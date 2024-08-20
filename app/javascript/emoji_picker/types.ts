interface EmojiDataBase {
  symbol: string;
}

export interface EmojiDataWithName extends EmojiDataBase {
  name: string;
  boostedName?: never;
}

export interface EmojiDataWithBoostedName extends EmojiDataBase {
  name?: never;
  boostedName: string;
}

export type EmojiData = EmojiDataWithName | EmojiDataWithBoostedName;
