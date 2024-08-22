export * from '@/types/serializers';

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
