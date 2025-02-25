export * from '@/types/serializers';

// Helper to detect if a property is optional.
/* eslint-disable @typescript-eslint/no-empty-object-type */
type IsOptional<T, K extends keyof T> = {} extends Pick<T, K> ? true : false;

// Split the common keys into optional and required groups.
// A key is considered optional if it’s optional in both T and U.
type OptionalKeys<T, U> = {
  [K in Extract<keyof T, keyof U>]: IsOptional<T, K> extends true ?
    IsOptional<U, K> extends true ?
      K
    : never
  : {} extends Pick<U, K> ? K
  : never;
}[Extract<keyof T, keyof U>];
type RequiredKeys<T, U> = Exclude<
  Extract<keyof T, keyof U>,
  OptionalKeys<T, U>
>;

// For primitive (non‑object) types, we “intersect” by using a conditional that
// works when the types are identical.
type IntersectionPrimitive<T, U> = T extends U ? T : never;

// For objects, we process required and optional keys separately.
/* eslint-disable no-use-before-define */
type IntersectionObject<T, U> = {
  // For keys that end up required: if one side is optional, we remove undefined
  // (but we do not touch null)
  [K in RequiredKeys<T, U>]: {} extends Pick<T, K> ?
    Intersection<Exclude<T[K], undefined>, U[K]>
  : {} extends Pick<U, K> ? Intersection<T[K], Exclude<U[K], undefined>>
  : Intersection<T[K], U[K]>;
} & {
  // For keys that are optional on both sides, remove undefined so that the
  // “present” type stays as declared.
  [K in OptionalKeys<T, U>]?: Intersection<
    Exclude<T[K], undefined>,
    Exclude<U[K], undefined>
  >;
};
/* eslint-enable @typescript-eslint/no-empty-object-type */

// Base intersection: handle arrays and objects.
type BaseIntersection<T, U> =
  T extends Array<infer TItem> ?
    U extends Array<infer UItem> ?
      Array<Intersection<TItem, UItem>>
    : never
  : T extends object ?
    U extends object ?
      IntersectionObject<T, U>
    : IntersectionPrimitive<T, U>
  : IntersectionPrimitive<T, U>;
/* eslint-enable no-use-before-define */

// Helper to detect if a type includes an explicit null.
type HasNull<T> = [T] extends [Exclude<T, null>] ? false : true;

// Finally, the exported Intersection type.
// If either T or U include null in their union, we “peel off” null (using Exclude<…, null>)
// for the recursive work and then re‑add null to the result.
export type Intersection<T, U> =
  HasNull<T> extends true ?
    BaseIntersection<Exclude<T, null>, Exclude<U, null>> | null
  : HasNull<U> extends true ?
    BaseIntersection<Exclude<T, null>, Exclude<U, null>> | null
  : BaseIntersection<T, U>;

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
