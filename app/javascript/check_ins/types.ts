import {
  CheckIn,
  NeedSatisfactionRating as TypelizerNeedSatisfactionRating,
  UserSerializerBasic,
} from '@/types';

export type Rating = -3 | -2 | -1 | 0 | 1 | 2 | 3;

export interface NeedSatisfactionRating
  extends TypelizerNeedSatisfactionRating {
  score: Rating;
}

export interface Bootstrap {
  current_user: UserSerializerBasic;
  check_in: CheckIn;
  partner_ratings_hidden_reason: string | null;
  partner_ratings_of_user: Array<NeedSatisfactionRating>;
  user_ratings_of_partner: Array<NeedSatisfactionRating>;
}
