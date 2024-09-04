export * from '@/types/serializers';

export type Intersection<T, U> = {
  [K in Extract<keyof T, keyof U>]: T[K];
};

// begin logs >>
export type LogEntryDataValue = string | number;
// << end logs

// begin emoji picker >>
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
// << end emoji picker

// begin workout >>
export type RepTotals = { [key: string]: number };

export type Exercise = {
  name?: string;
  reps?: number;
};

export type WorkoutPlan = {
  minutes: number;
  numberOfSets: number;
  exercises: Array<Exercise>;
};
// << end workout
