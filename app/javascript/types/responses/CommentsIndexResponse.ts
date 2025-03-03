export type CommentsIndexResponse = Array<CommentsIndexResponseElement>

interface CommentsIndexResponseElement {
    content:    string;
    created_at: string;
    id:         number;
    parent_id:  number | null;
    user:       User | null;
}

interface User {
    gravatar_url: string;
    id:           number;
    public_name:  string;
}
