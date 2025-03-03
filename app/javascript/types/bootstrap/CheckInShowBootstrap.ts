export interface CheckInShowBootstrap {
    check_in:                       CheckIn;
    current_user:                   CurrentUser;
    nonce:                          string;
    partner_ratings_hidden_reason?: string;
    partner_ratings_of_user:        Rating[];
    user_ratings_of_partner:        Rating[];
}

interface CheckIn {
    id:        number;
    submitted: boolean;
}

interface CurrentUser {
    email: string;
    id:    number;
}

interface Rating {
    emotional_need: EmotionalNeed;
    id:             number;
    score:          number | null;
}

interface EmotionalNeed {
    description: string;
    id:          number;
    name:        string;
}
