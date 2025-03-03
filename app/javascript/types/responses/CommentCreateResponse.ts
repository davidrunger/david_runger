export interface CommentCreateResponse {
    content:    string;
    created_at: string;
    id:         number;
    parent_id:  number | null;
    user:       User;
}

interface User {
    gravatar_url: string;
    id:           number;
    public_name:  string;
}
