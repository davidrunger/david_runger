// This is a generated file. Do not edit this file directly.

export interface QuizShowBootstrap {
    current_user: CurrentUser;
    nonce:        string;
    quiz:         Quiz;
}

interface CurrentUser {
    email: string;
    id:    number;
}

interface Quiz {
    hashid:   string;
    owner_id: number;
}

