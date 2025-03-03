export interface NeedSatisfactionRatingShowResponse {
    emotional_need?: EmotionalNeed;
    id?:             number;
    score?:          number;
}

interface EmotionalNeed {
    description?: string;
    id?:          number;
    name?:        string;
}
