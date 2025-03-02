import type { Intersection } from '@/types';

/* eslint-disable @typescript-eslint/no-unused-expressions */

type AssertEqual<T, Expected> =
  T extends Expected ?
    Expected extends T ?
      true
    : never
  : never;

// Test optional property handling.
() => {
  type Result = Intersection<{ a?: string }, { a: string }>;
  type Expected = { a: string };
  const test: AssertEqual<Result, Expected> = true;
  test;
};

// Test null handling.
() => {
  type Result = Intersection<{ a: null | string }, { a: null | string }>;
  type Expected = { a: null | string };
  const test: AssertEqual<Result, Expected> = true;
  test;
};

// Test optional property and null handling.
() => {
  type Result = Intersection<{ a?: string | null }, { a?: string | null }>;
  type Expected = { a?: string | null };
  const test: AssertEqual<Result, Expected> = true;
  test;
};

// Test array handling.
() => {
  const arrayIntersection: Intersection<
    Array<{ a: string }>,
    Array<{ a: string }>
  > = [
    {
      a: 'some string',
    },
  ];
  arrayIntersection;
};
