export interface CheckIn {
  id: number
  submitted: boolean
}

export interface EmotionalNeed {
  description?: string
  id: number
  name: string
}

export type Rating = -3 | -2 | -1 | 0 | 1 | 2 | 3;

export interface NeedSatisfactionRating {
  id: number
  score: Rating
  emotional_need: EmotionalNeed
}

export interface Bootstrap {
  current_user: {
    id: number
  }
  check_in: CheckIn
  partner_ratings_hidden_reason: string | null
  partner_ratings_of_user: Array<NeedSatisfactionRating>
  user_ratings_of_partner: Array<NeedSatisfactionRating>
}
