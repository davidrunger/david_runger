export interface LogCreateResponse {
    data_label:               string;
    data_type:                string;
    description:              null | string;
    id:                       number;
    log_shares:               User[];
    name:                     string;
    publicly_viewable:        boolean;
    reminder_time_in_seconds: number | null;
    slug:                     string;
    user:                     User;
}

interface User {
    email: string;
    id:    number;
}
