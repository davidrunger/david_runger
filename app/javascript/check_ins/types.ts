import type {
  CheckIn,
  Intersection,
  NeedSatisfactionRating as TypelizerNeedSatisfactionRating,
  UserSerializerBasic,
} from '@/types';
import { CheckInShowBootstrap } from '@/types/bootstrap/CheckInShowBootstrap';

export type RatedUser = 'partner' | 'self';

export type Rating = -3 | -2 | -1 | 0 | 1 | 2 | 3;

export interface NeedSatisfactionRating extends TypelizerNeedSatisfactionRating {
  score: Rating | null;
}

export type Bootstrap = Intersection<
  {
    current_user: UserSerializerBasic;
    check_in: CheckIn;
    partner_ratings_hidden_reason: string | null;
    partner_ratings_of_user: Array<NeedSatisfactionRating>;
    user_ratings_of_partner: Array<NeedSatisfactionRating>;
  },
  CheckInShowBootstrap
>;
